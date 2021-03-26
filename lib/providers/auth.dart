import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  // We have added the ChangeNotifier mixin so that we can call notifyListeners to make sure all places
  // in the UI which depend on our auth logic aur updated when it changes.
  String _token;
  DateTime _expiryDate; // Since token expires after a period
  // of time, we have to make a DateTime object too
  String _userId;
  // Note that none of the properties are final because all of them will be able to change
  // across the lifetime of our app for eg if we log out, all of them will be cleared

  Timer _authTimer;

  bool get isAuth {
    // We just have to check if we have a token and the token didn't expire
    // which'll tell us that the user is authenticated. So we'll add another getter: token
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // confirmPassword is not required here as we only use it in our form inside the validation.
    // It's just there to validate our i/p we don't need to submit it to server.
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAvg9JXnc8dDwi9BrdPxxtleX3aEIehLn4');
    // This URL is taken from Firebase docs but this a dynamic segment at the end
    // which is the API key we will get from our FireBase project in project settings under Web API key
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
 // getInstance returns a future which eventually returns a SharedPreference
 // So we should await that so that we don't store the future in here but the
 // real access to shared preferences 
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
// We have encoded the map into JSON bcoz JSON is a string and now we can 
// use set methods to write Data
      prefs.setString('userData', userData);
// set methods are used to write data
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
// It is returning boolean bcoz we want to know whether we were successful
// while trying to auto login the user or not
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
// There is no data in the userData key so we won't have a valid token
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
// to check if the token has expired
      return false;
    }
// Now our token is valid so we want to reinitialize all our properties
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout(); // to set the timer again
    return true; // to know that we succeeded
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData'); 
// This would be good if we are storing multiple things in the shared
// preferences and we don't want to delete them all
    prefs.clear();
// But if we know we only store userData there, we can just call prefs.clear
  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}

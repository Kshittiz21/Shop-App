import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/splash_screen.dart';
import './screens/edit_product_Screen.dart';
import './screens/orders_screen.dart';

import './screens/cart_screen.dart';
import './providers/cart.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
// We have used ChangeNotifierProxyProvider here (so we have to use update
// instead of create) bcoz here that update apart from context also gives us a
// dynamic value which is very useful. ChangeNotifierProxyProvider is a generic
// class and we have to add angular brackets to give extra information.
// This allows us to setup a provider which itself depends on some other provider
// which was defined b4 it(IMPORTANT). So we will add Auth inside angular brackets
// and then dart will look if we have a provider which provides an Auth object b4
// itself and then gives that object to update and now whenevr auth changes, this
// provider also rebuilds. Apart from giving the class we depend on, we also have
// to give the type of data/class we provide here which is Products and then pass
// its object to update too which takes the previous state of ur current class which
// is used to maintain the state. And then after giving all these parameters to update,
// we pass a new instance to Products class and pass auth.token to it as a parameter.
// We also have to make sure that when we rebuilt and make a new instance of this ,
// we don't lose all the data we had b4 bcoz in products, we had the list of products
// So we initialize this._items also inside the constructor in products.dart and here,
// we will pass previousProducts.items too with auth.token
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
// if we are not authenticated, we don't want to show the Auth screen 
// directly but try logging in
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

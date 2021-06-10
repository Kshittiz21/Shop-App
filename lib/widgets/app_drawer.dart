import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Drawer(
        child: Column(
          children: [
            AppBar(
              title: Text('Hello Friend!'),
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text('Shop'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text('Orders'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(OrdersScreen.routeName);
                // Navigator.of(context).pushReplacement(CustomRoute(
                //   builder: (ctx) => OrdersScreen(),
                // ));
                
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(UserProductsScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
               leading: Icon(Icons.exit_to_app),
              title: Text('LogOut'),
              onTap: () {
                Navigator.of(context).pop();
                // We have popped this drawer first because otherwise it will be
                // hard closed which gives us error.
                Navigator.of(context).pushReplacementNamed('/');
                // So that we always go to the Auth Screen when we clear our data
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/new_stock_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creación de Portafolio',
      initialRoute: MainScreen.route,
      routes: {
        MainScreen.route: (context) => MainScreen(),
        AuthScreen.route: (context) => AuthScreen(),
        NewStockScreen.route: (context) => NewStockScreen(),
      },
    );
  }
}

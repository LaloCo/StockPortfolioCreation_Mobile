import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'package:stockportfoliocreationmobile/widgets/stock_picks_list.dart';

class MainScreen extends StatefulWidget {
  static const String route = '/main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();

    evaluateIfLoggedIn();
  }

  void evaluateIfLoggedIn() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        currentUser = user;
      } else {
        Navigator.pushNamed(context, AuthScreen.route);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creación de Portafolio'),
      ),
      body: SafeArea(
        child: StockPicksList(
          currentUser: currentUser,
        ),
      ),
    );
  }
}

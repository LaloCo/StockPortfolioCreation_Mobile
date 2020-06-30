import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'package:stockportfoliocreationmobile/widgets/stock_picks_list.dart';
import 'package:stockportfoliocreationmobile/widgets/portfolio_list.dart';

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
        setState(() {
          currentUser = user;
        });
      } else {
        Navigator.pushNamed(context, AuthScreen.route);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Creación de Portafolio'),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushNamed(context, AuthScreen.route);
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work)),
              Tab(icon: Icon(Icons.apps)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SafeArea(
              child: PortfolioList(
                currentUser: currentUser,
              ),
            ),
            SafeArea(
              child: StockPicksList(
                currentUser: currentUser,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigoAccent,
          child: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );
  }
}

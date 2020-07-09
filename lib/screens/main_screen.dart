import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockportfoliocreationmobile/screens/new_stock_screen.dart';
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
  String userId = '';

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
          userId = user.uid;
          print(userId);
        });
      } else {
        authenticate();
      }
    } catch (e) {
      print(e);
    }
  }

  void authenticate() async {
    String received = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AuthScreen()));
    print('RECEIVED: ' + received);
    setState(() {
      userId = received;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
        ),
      );
    }
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
                setState(() {
                  userId = '';
                });
                authenticate();
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
                userId: userId,
              ),
            ),
            SafeArea(
              child: StockPicksList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigoAccent,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, NewStockScreen.route);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockportfoliocreationmobile/screens/new_stock_screen.dart';
import 'auth_screen.dart';
import 'package:stockportfoliocreationmobile/widgets/stock_picks_list.dart';
import 'package:stockportfoliocreationmobile/widgets/portfolio_list.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MainScreen extends StatefulWidget {
  static const String route = '/main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  String userId = '';
  FirebaseUser currentUser;
  bool enablePlusButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    evaluateIfLoggedIn();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      currentUser = await _auth.currentUser();
      evaluateIfEmailIsVerified(currentUser);
    }

    super.didChangeAppLifecycleState(state);
  }

  void evaluateIfLoggedIn() async {
    try {
      currentUser = await _auth.currentUser();
      if (currentUser != null) {
        setState(() {
          userId = currentUser.uid;
        });

        evaluateIfEmailIsVerified(currentUser);
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
    currentUser = await _auth.currentUser();
    if (currentUser != null) {
      evaluateIfEmailIsVerified(currentUser);
    }
  }

  void evaluateIfEmailIsVerified(FirebaseUser user) async {
    await user.reload();
    user = await _auth.currentUser();
    if (!user.isEmailVerified) {
      showVerificationAlert(context, user);
    } else {
      setState(() {
        enablePlusButton = true;
      });
    }
  }

  void showVerificationAlert(BuildContext context, FirebaseUser user) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'Tu correo no está verificado',
      desc: 'Necesitamos verificar tu correo antes de poder continuar,' +
          ' por favor revisa tu bandeja de entrada.',
      buttons: [
        DialogButton(
          child: Text(
            'Volver a enviar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          color: Colors.red,
          onPressed: () async {
            await user.sendEmailVerification();
            Navigator.pop(context);
          },
        )
      ],
    ).show();
  }

  void navigateToNewStockScreen() {
    Navigator.pushNamed(context, NewStockScreen.route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
              child: enablePlusButton
                  ? PortfolioList(
                      userId: userId,
                    )
                  : Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Ya verifiqué mi correo',
                          style: TextStyle(
                            color: Colors.lightBlue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              evaluateIfEmailIsVerified(currentUser);
                            },
                        ),
                      ),
                    ),
            ),
            SafeArea(
              child: StockPicksList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor:
              enablePlusButton ? Colors.indigoAccent : Colors.grey.shade300,
          disabledElevation: 0,
          child: Icon(Icons.add),
          onPressed: enablePlusButton ? navigateToNewStockScreen : null,
        ),
      ),
    );
  }
}

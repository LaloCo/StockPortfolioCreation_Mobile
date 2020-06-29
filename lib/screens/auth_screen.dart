import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stockportfoliocreationmobile/constants.dart';
import 'package:stockportfoliocreationmobile/screens/main_screen.dart';
import 'package:stockportfoliocreationmobile/widgets/round_button.dart';

class AuthScreen extends StatefulWidget {
  static const String route = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  bool isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isBusy,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextInputDecoration.copyWith(hintText: 'Escribe tu email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: kTextInputDecoration.copyWith(
                    hintText: 'Escribe tu contraseña'),
              ),
              SizedBox(
                height: 24.0,
              ),
              MyRoundButton(
                text: 'Log In',
                backgroundColor: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    isBusy = true;
                  });
                  try {
                    final newUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print(e);

                    if (e.code == 'ERROR_USER_NOT_FOUND') {}
                  }
                  setState(() {
                    isBusy = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

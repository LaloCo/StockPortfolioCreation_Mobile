import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stockportfoliocreationmobile/constants.dart';
import 'package:stockportfoliocreationmobile/screens/main_screen.dart';
import 'package:stockportfoliocreationmobile/widgets/round_button.dart';

class RegisterScreen extends StatefulWidget {
  static const String route = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password, confirmPassword;
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
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  confirmPassword = value;
                },
                obscureText: true,
                decoration: kTextInputDecoration.copyWith(
                    hintText: 'Confirma tu contraseña'),
              ),
              SizedBox(
                height: 24.0,
              ),
              MyRoundButton(
                text: 'Regístrate',
                backgroundColor: Colors.lightBlueAccent,
                onPressed: () async {
                  if (password == confirmPassword) {
                    setState(() {
                      isBusy = true;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    } catch (e) {
                      print(e);

                      //TODO: evaluate potential errors
                    }
                    setState(() {
                      isBusy = false;
                    });
                  } else {
                    //TODO: Show different password alert
                  }
                },
              ),
              RichText(
                text: TextSpan(
                  text: '¿Ya tienes una cuenta?',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Inicia sesión',
                      style: TextStyle(
                        color: Colors.lightBlue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

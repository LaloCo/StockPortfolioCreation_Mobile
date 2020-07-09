import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stockportfoliocreationmobile/constants.dart';
import 'package:stockportfoliocreationmobile/widgets/round_button.dart';

class AuthScreen extends StatefulWidget {
  static const String route = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  String registerEmail, registerPassword, confirmPassword;
  bool isBusy = false;
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
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
                  decoration: kTextInputDecoration.copyWith(
                      hintText: 'Escribe tu email'),
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
                  text: 'Iniciar sesión',
                  backgroundColor: Colors.lightBlueAccent,
                  onPressed: () async {
                    setState(() {
                      isBusy = true;
                    });
                    try {
                      final newUser = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (newUser != null) {
                        Navigator.pop(context, newUser.user.uid);
                      }
                    } catch (e) {
                      print(e);

                      if (e.code == 'ERROR_USER_NOT_FOUND') {
                        //TODO: Show alert to user
                      }
                    }
                    setState(() {
                      isBusy = false;
                    });
                  },
                ),
                RichText(
                  text: TextSpan(
                    text: '¿No tienes una cuenta?',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Regístrate',
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              isLogin = false;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
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
                    registerEmail = value;
                  },
                  decoration: kTextInputDecoration.copyWith(
                      hintText: 'Escribe tu email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  onChanged: (value) {
                    registerPassword = value;
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
                    if (registerPassword == confirmPassword) {
                      setState(() {
                        isBusy = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: registerEmail,
                                password: registerPassword);
                        if (newUser != null) {
                          Navigator.pop(context, newUser.user.uid);
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
                          ..onTap = () {
                            setState(() {
                              isLogin = true;
                            });
                          },
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
}

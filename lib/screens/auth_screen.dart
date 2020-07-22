import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stockportfoliocreationmobile/constants.dart';
import 'package:stockportfoliocreationmobile/widgets/round_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AuthScreen extends StatefulWidget {
  static const String route = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '', password = '';
  String registerEmail = '', registerPassword = '', confirmPassword = '';
  String errorMessage = '';
  bool isBusy = false;
  bool isLogin = true;

  void forgotPassword() {
    if (email.isEmpty) {
      Alert(
        context: context,
        title: "Escribe tu correo",
        desc:
            "Escribe tu correo electrónico para enviarte los pasos para cambiar tu contraseña.",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ).show();
    } else {
      _auth.sendPasswordResetEmail(email: email).then((value) {
        Alert(
          context: context,
          title: "Enviado",
          desc:
              "Las instrucciones para recuperar tu contraseña han sido enviadas a tu correo.",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ).show();
      }).catchError((error) {
        print(error);
      });
    }
  }

  void setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void login() async {
    if (email.isEmpty) {
      setErrorMessage('El correo no puede estar vacío.');
      return;
    }
    if (password.isEmpty) {
      setErrorMessage('La contraseña no puede estar vacía.');
      return;
    }

    setState(() {
      isBusy = true;
    });
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result != null) {
        Navigator.pop(context, result.user.uid);
      }
    } on PlatformException catch (e) {
      print(e.toString());

      if (e.code == 'ERROR_INVALID_EMAIL') {
        setErrorMessage('El correo no tiene el formato correcto');
      } else if (e.code == 'ERROR_USER_NOT_FOUND') {
        setErrorMessage('Este correo no está asociado a nunguna cuenta.');
      } else if (e.code == 'ERROR_WRONG_PASSWORD') {
        setErrorMessage('La contraseña es incorrecta.');
      } else {
        if (e.details != null) {
          setErrorMessage(e.details);
        } else {
          setErrorMessage('Un error desconocido ocurrió.');
        }
      }
    } catch (e) {
      print(e.toString());

      setErrorMessage('Un error desconocido ocurrió');
    }

    setState(() {
      isBusy = false;
    });
  }

  void register() async {
    if (registerEmail.isEmpty) {
      setErrorMessage('El correo no puede estar vacío.');
      return;
    }
    if (registerPassword.isEmpty) {
      setErrorMessage('La contraseña no puede estar vacía.');
      return;
    }
    if (confirmPassword.isEmpty) {
      setErrorMessage('Debes confirmar tu contraseña.');
      return;
    }

    if (registerPassword == confirmPassword) {
      setState(() {
        isBusy = true;
      });
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: registerEmail, password: registerPassword);
        if (newUser != null) {
          // send email verification since user is new
          await newUser.user.sendEmailVerification();
          Navigator.pop(context, newUser.user.uid);
        }
      } on PlatformException catch (e) {
        print(e.toString());

        if (e.code == 'ERROR_INVALID_EMAIL') {
          setErrorMessage('El correo no tiene el formato correcto');
        } else if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          setErrorMessage('Este correo ya está asociado a una cuenta.');
        } else if (e.code == 'ERROR_WEAK_PASSWORD') {
          setErrorMessage('La contraseña debe ser de al menos 6 caracteres.');
        } else {
          if (e.details != null) {
            setErrorMessage(e.details);
          } else {
            setErrorMessage('Un error desconocido ocurrió.');
          }
        }
      } catch (e) {
        print(e.toString());

        setErrorMessage('Un error desconocido ocurrió');
      }
      setState(() {
        isBusy = false;
      });
    } else {
      setErrorMessage('Las contraseñas son diferentes.');
    }
  }

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
                  height: 8.0,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                MyRoundButton(
                  text: 'Iniciar sesión',
                  backgroundColor: Colors.lightBlueAccent,
                  onPressed: login,
                ),
                SizedBox(
                  height: 8.0,
                ),
                RichText(
                  text: TextSpan(
                    text: '¿No tienes una cuenta?',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16.0,
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
                              errorMessage = "";
                              isLogin = false;
                            });
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                RichText(
                  text: TextSpan(
                    text: '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 16.0,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = forgotPassword,
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
                  height: 8.0,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                MyRoundButton(
                  text: 'Regístrate',
                  backgroundColor: Colors.lightBlueAccent,
                  onPressed: register,
                ),
                SizedBox(
                  height: 8.0,
                ),
                RichText(
                  text: TextSpan(
                    text: '¿Ya tienes una cuenta?',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16.0,
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
                              errorMessage = "";
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

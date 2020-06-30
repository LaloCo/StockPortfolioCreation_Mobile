import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stockportfoliocreationmobile/constants.dart';

class NewStockScreen extends StatefulWidget {
  static const String route = '/new';

  @override
  _NewStockScreenState createState() => _NewStockScreenState();
}

class _NewStockScreenState extends State<NewStockScreen> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  String symbol;
  DateTime dateOfPurchase = DateTime.now();
  bool isBusy = false;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    var user = await _auth.currentUser();
    setState(() {
      currentUser = user;
    });
  }

  void saveStock() async {
    if (symbol.trim().length > 0) {
      setState(() {
        isBusy = true;
      });
      var insertedItem = await _firestore.collection('portfolio').add({
        'author': currentUser.uid,
        'created_at': dateOfPurchase,
        'symbol': symbol
      });
      if (insertedItem != null) {
        Navigator.pop(context);
      } else {
        //TODO: show error message
      }
    } else {
      //TODO: Show error message
    }
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Agregar al portafolio'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveStock();
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: isBusy,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  symbol = value;
                },
                decoration: kTextInputDecoration.copyWith(
                    hintText: 'Acción que compraste'),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text('Fecha en que la compraste:'),
              SizedBox(
                height: 8.0,
              ),
              CalendarDatePicker(
                firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
                onDateChanged: (value) {
                  dateOfPurchase = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

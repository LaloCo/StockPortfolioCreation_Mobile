import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PortfolioList extends StatelessWidget {
  final _firestore = Firestore.instance;
  final String userId;

  PortfolioList({@required this.userId});

  void DeleteStock(DocumentSnapshot stock) async {
    try {
      await _firestore
          .collection('portfolio')
          .document(stock.documentID)
          .delete();
    } catch (ex) {
      print(ex);
    }
  }

  void ShowAlert(BuildContext context, DocumentSnapshot stock) {
    final date = stock.data['created_at'];
    DateTime purchaseDate =
        DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
    DateTime sellByDate = purchaseDate.add(Duration(days: 365));
    Alert(
      context: context,
      type: AlertType.info,
      title: stock.data['symbol'],
      desc: 'Comprada el ' +
          DateFormat.yMMMMd().format(purchaseDate) +
          '. Vender para el ' +
          DateFormat.yMMMMd().format(sellByDate),
      buttons: [
        DialogButton(
          child: Text(
            'Borrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          color: Colors.red,
          onPressed: () {
            DeleteStock(stock);
            Navigator.pop(context);
          },
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // filtering by author requires the creation of an index
      // back in the Firestore database
      stream: _firestore
          .collection('portfolio')
          .where('author', isEqualTo: userId)
          .orderBy('created_at')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        List<Widget> messageWidgets = [];
        final stocks = snapshot.data.documents;
        for (var stock in stocks) {
          final name = stock.data['symbol'];
          final date = stock.data['created_at'];
          DateTime dtDate =
              DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
          int diffDays = dtDate
              .difference(DateTime.now().add(Duration(days: -365)))
              .inDays;

          final stockWidget = GestureDetector(
            onTap: () {
              ShowAlert(context, stock);
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Material(
                elevation: 5.0,
                color: Colors.indigo,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        'Comprada el ' + DateFormat.yMMMMd().format(dtDate),
                        style: TextStyle(
                          color: diffDays <= 0
                              ? Colors.red
                              : diffDays <= 7 ? Colors.yellow : Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          messageWidgets.add(stockWidget);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

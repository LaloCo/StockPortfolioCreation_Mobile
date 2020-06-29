import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockPicksList extends StatelessWidget {
  final _firestore = Firestore.instance;
  final FirebaseUser currentUser;

  StockPicksList({@required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('stock_picks')
          .orderBy('overall_ranking')
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
          final name = stock.data['name'];
          final symbol = stock.data['symbol'];

          final stockWidget = Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Material(
                elevation: 5.0,
                color: Colors.grey.shade600,
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
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        symbol,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
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

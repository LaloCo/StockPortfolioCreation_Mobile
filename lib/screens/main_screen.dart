import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static const String route = '/main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creación de Portafolio'),
      ),
      body: SafeArea(
        child: Text(
          'Placeholder',
        ),
      ),
    );
  }
}

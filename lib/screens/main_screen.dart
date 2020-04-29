import 'package:flutter/material.dart';
import 'package:umix/screens/sign_in_screen.dart';
import 'package:umix/screens/splash_screen.dart';

class MainScreen extends StatefulWidget {
  static const route = 'main';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.power_settings_new), onPressed: () { 
            SplashScreen.mAuth.signOut();
            Navigator.of(context).pushReplacementNamed(SignIn.route);
          })
        ],
      ),
      body: Center(
        child: Text(
          SplashScreen.mUser.uid
        ),
      ),
    );
  }
}
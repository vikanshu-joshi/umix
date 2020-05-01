import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umix/screens/main_screen.dart';
import 'package:umix/screens/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatelessWidget {
  static const route = 'splash';
  static FirebaseUser mUser;
  static FirebaseAuth mAuth = FirebaseAuth.instance;
  static CollectionReference userRef = Firestore.instance.collection('users');

  void move(BuildContext context, String route) {
    Future.delayed(Duration(milliseconds: 1000)).then((onValue) {
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    mAuth.currentUser().then((user) {
      mUser = user;
      if (SplashScreen.mUser == null) {
        move(context, SignIn.route);
      } else {
        move(context, MainScreen.route);
      }
    });
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: OrientationBuilder(builder: (ctx, orientation) {
        return Center(
          child: Image.asset(
            'assets/images/splash.png',
            width: orientation == Orientation.portrait
                ? mediaQuery.size.width * 0.55
                : mediaQuery.size.width * 0.4,
          ),
        );
      }),
    );
  }
}

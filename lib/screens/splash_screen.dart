import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umix/screens/main_screen.dart';
import 'package:umix/screens/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:umix/models/user.dart';

class SplashScreen extends StatelessWidget {
  static const route = 'splash';
  static FirebaseUser mUser;
  static FirebaseAuth mAuth = FirebaseAuth.instance;
  static CollectionReference userRef = Firestore.instance.collection('users');
  static User myProfile;

  void move(BuildContext context, String route) {
    Future.delayed(Duration(milliseconds: 1000)).then((onValue) {
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  Future<bool> fetchMyProfile() async {
    var status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      fetchMyProfile();
    } else {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      userRef.document(mUser.uid).get().then((data) {
        _prefs.setString('name', data['name']);
        _prefs.setString('email', data['email']);
        _prefs.setString('dob', data['dob']);
        _prefs.setString('gender', data['gender']);
        _prefs.setString('image', data['image']);
        _prefs.setString('uid', data['uid']);
        myProfile = User(data['name'], data['email'], data['dob'],
            data['gender'], data['image'], data['uid']);
      }).catchError((error) {
        myProfile = User(
            _prefs.getString('name'),
            _prefs.getString('email'),
            _prefs.getString('dob'),
            _prefs.getString('gender'),
            _prefs.getString('image'),
            mUser.uid);
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    mAuth.currentUser().then((user) {
      mUser = user;
      if (SplashScreen.mUser == null) {
        move(context, SignIn.route);
      } else {
        fetchMyProfile().then((_) {
          move(context, MainScreen.route);
        });
      }
    });
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: OrientationBuilder(builder: (ctx, orientation) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/splash.png',
              width: orientation == Orientation.portrait
                  ? mediaQuery.size.width * 0.55
                  : mediaQuery.size.width * 0.4,
            ),
            Container(
              padding: const EdgeInsets.all(50),
              child: CupertinoActivityIndicator(
                animating: true,
              ),
            )
          ],
        ));
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:umix/screens/create_new_account.dart';
import 'package:umix/screens/main_screen.dart';
import 'package:umix/screens/sign_in_screen.dart';
import 'package:umix/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMIX',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.deepPurpleAccent,
        primaryColor: Colors.purple,
      ),
      home: SplashScreen(),
      routes: {
        SplashScreen.route: (ctx) => SplashScreen(),
        SignIn.route: (ctx) => SignIn(),
        CreateAccount.route: (ctx) => CreateAccount(),
        MainScreen.route: (ctx) => MainScreen()
      },
    );
  }
}

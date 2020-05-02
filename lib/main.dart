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
        accentColor: Colors.amber,
        primaryColor: Color.fromRGBO(45, 207, 197, 1),
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

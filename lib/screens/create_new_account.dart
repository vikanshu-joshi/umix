import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  static const route = 'create';
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Account'),
      ),
      backgroundColor: Colors.white,
      body: Center(child: Text('Create New Account'),),
    );
  }
}
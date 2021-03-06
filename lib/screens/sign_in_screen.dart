import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:umix/screens/create_new_account.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class SignIn extends StatefulWidget {
  static const route = 'sign in';
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _showPassword = false;
  ProgressDialog _progressDialog;

  void _passwordVisibleStateChnaged(bool _newState) {
    setState(() {
      _showPassword = _newState;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget getLayout(MediaQueryData mediaQuery, BuildContext context) {
    return SingleChildScrollView(
      padding: mediaQuery.size.width >= mediaQuery.size.height
          ? EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20)
          : EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Form(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Device.get().isIos
                      ? CupertinoTextField(
                          controller: _email,
                          placeholder: 'Email',
                          autofocus: false,
                          enableInteractiveSelection: true,
                          clearButtonMode: OverlayVisibilityMode.editing,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Theme.of(context).primaryColor,
                        )
                      : TextFormField(
                          controller: _email,
                          autofocus: false,
                          decoration: InputDecoration(hintText: 'Email'),
                          cursorColor: Theme.of(context).primaryColor,
                        ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Device.get().isIos
                        ? CupertinoTextField(
                            controller: _password,
                            autofocus: false,
                            placeholder: 'Password',
                            enableInteractiveSelection: true,
                            clearButtonMode: OverlayVisibilityMode.editing,
                            obscureText: true,
                            cursorColor: Theme.of(context).primaryColor,
                          )
                        : TextFormField(
                            controller: _password,
                            autofocus: false,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(hintText: 'Password'),
                          ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('***'),
                Switch.adaptive(
                    value: _showPassword,
                    onChanged: (newValue) {
                      _passwordVisibleStateChnaged(newValue);
                    }),
                Text('ABC')
              ],
            ),
          ),
          Device.get().isIos
              ? CupertinoButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _signInPressed(context))
              : RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _signInPressed(context),
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          Container(
            margin: EdgeInsets.only(top: 30),
            child: GestureDetector(
              onTap: () => createNewAccount(context),
              child: Text(
                'Create New Account',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logIn(String email, String pass, BuildContext context) async {
    _progressDialog.show();
    try {
      AuthResult result = await SplashScreen.mAuth
          .signInWithEmailAndPassword(email: email.trim(), password: pass);
      SplashScreen.mUser = result.user;
      _progressDialog.hide();
      Navigator.of(context).pushReplacementNamed(SplashScreen.route);
    } catch (error) {
      if (Device.get().isAndroid) {
        _progressDialog.hide();
        showAlertError(error.message, context);
      } else if (Device.get().isIos) {
        _progressDialog.hide();
        showAlertError(error.code, context);
      }
    }
  }

  void _signInPressed(BuildContext context) {
    if (_email.text.isEmpty) {
      showAlertError('Email Field Empty', context);
    } else if (_password.text.isEmpty) {
      showAlertError('Password Field Empty', context);
    } else {
      logIn(_email.text, _password.text, context);
    }
  }

  void createNewAccount(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(CreateAccount.route);
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = ProgressDialog(context,
        isDismissible: true, type: ProgressDialogType.Normal);
    _progressDialog.style(
      progressWidget: Container(
        padding: const EdgeInsets.all(15.0),
        child: CircularProgressIndicator(),
      ),
      elevation: 2,
      message: 'Please Wait.....',
      borderRadius: 5,
    );
    var mediaQuery = MediaQuery.of(context);
    var _body = getLayout(mediaQuery, context);
    return Device.get().isIos
        ? CupertinoPageScaffold(
            child: _body,
            navigationBar: CupertinoNavigationBar(
              middle: Text('Sign In'),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Sign In'),
            ),
            backgroundColor: Colors.white,
            body: _body,
          );
  }
}

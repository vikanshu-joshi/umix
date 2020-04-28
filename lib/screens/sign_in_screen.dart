import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/screens/create_new_account.dart';

class SignIn extends StatefulWidget {
  static const route = 'sign in';
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FirebaseUser currentUser;
  FirebaseAuth mAuth;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _showPassword = false;

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

  @override
  void initState() {
    super.initState();
    mAuth = FirebaseAuth.instance;
  }

  Widget portraitLayout(MediaQueryData mediaQuery,BuildContext context) {
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

  Widget landscapeLayout(MediaQueryData mediaQuery,BuildContext context) {
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
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                  GestureDetector(
                    onTap: () => createNewAccount(context),
                    child: Text(
                      'Create New Account',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _signInPressed(context),
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAlertError(String error) {
    showDialog(
        context: context,
        builder: (_) {
          return Device.get().isIos
              ? CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(error),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text('Error'),
                  content: Text(error),
                  elevation: 5.0,
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'))
                  ],
                );
        });
  }

  void logIn(String email, String pass) async {
    try {
      AuthResult result =
          await mAuth.signInWithEmailAndPassword(email: email, password: pass);
      currentUser = result.user;
    } catch (error) {
      if (Device.get().isAndroid) {
        showAlertError(error.message);
      } else if (Device.get().isIos) {
        showAlertError(error.code);
      }
    }
  }

  void _signInPressed(BuildContext context) {
    if (_email.text.isEmpty) {
      showAlertError('Email Field Empty');
    } else if (_password.text.isEmpty) {
      showAlertError('Password Field Empty');
    }
    else {
      logIn(_email.text, _password.text);
    }
  }

  void createNewAccount(BuildContext context){
    Navigator.of(context).pushReplacementNamed(CreateAccount.route);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var _body = OrientationBuilder(
      builder: (ctx, orientation) {
        return orientation == Orientation.portrait
            ? portraitLayout(mediaQuery,context)
            : landscapeLayout(mediaQuery,context);
      },
    );
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

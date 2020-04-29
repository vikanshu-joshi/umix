import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:umix/models/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:umix/screens/main_screen.dart';
import 'package:umix/screens/splash_screen.dart';

class CreateAccount extends StatefulWidget {
  static const route = 'create';
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool _passwordShow = true;
  DateTime date;
  Gender _userGender = Gender.Other;
  TextEditingController _email = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _pass = TextEditingController();
  ProgressDialog _progressDialog;
  var format = DateFormat.yMMMMd();

  void changePassState() {
    setState(() {
      _passwordShow = !_passwordShow;
    });
  }

  void showAlertError(String error, BuildContext context) {
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

  void createAccount(BuildContext context) async {
    if (_name.text.trim().isEmpty) {
      showAlertError('Name field empty', context);
    } else if (_email.text.trim().isEmpty) {
      showAlertError('Email field empty', context);
    } else if (_pass.text.isEmpty) {
      showAlertError('Password field empty', context);
    } else if (date == null) {
      showAlertError('Date of Birth not set', context);
    } else {
      Device.get().isIos
          ? showDialog(
              context: context,
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CupertinoActivityIndicator()))
          : await _progressDialog.show();
      firebase(context);
    }
  }

  void firebase(BuildContext context) async {
    try {
      AuthResult result = await SplashScreen.mAuth
          .createUserWithEmailAndPassword(
              email: _email.text.trim().toString(),
              password: _pass.text.trim().toString());
      SplashScreen.mUser = result.user;
      Map<String, String> data = {
        'name': _name.text.trim(),
        'dob': format.format(date),
        'gender': _userGender == Gender.Other
            ? 'Other'
            : _userGender == Gender.Male ? 'Male' : 'Female',
        'email': _email.text.trim(),
        'uid': SplashScreen.mUser.uid
      };
      SplashScreen.userRef = Firestore.instance.collection('users');
      try {
        await SplashScreen.userRef
            .document(SplashScreen.mUser.uid)
            .setData(data);
        Device.get().isIos
            ? Navigator.of(context).pop()
            : await _progressDialog.hide();
        Navigator.of(context).pushReplacementNamed(MainScreen.route);
      } catch (error) {
        Device.get().isIos
            ? Navigator.of(context).pop()
            : await _progressDialog.hide();
        showAlertError(error.message, context);
      }
    } catch (error) {
      Device.get().isIos
          ? Navigator.of(context).pop()
          : await _progressDialog.hide();
      showAlertError(error.toString(), context);
    }
  }

  void getDOB(BuildContext context) {
    Device.get().isIos
        ? CupertinoDatePicker(
            maximumDate: DateTime.now(),
            minimumDate: DateTime.utc(1980),
            onDateTimeChanged: (_date) {
              setState(() {
                date = _date;
              });
            })
        : DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime.utc(1980),
            theme: DatePickerTheme(
              backgroundColor: Colors.white,
            ),
            maxTime: DateTime.now(), onConfirm: (_date) {
            setState(() {
              date = _date;
            });
          });
  }

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            middle: Text('Create New Account'),
            trailing: IconButton(
              icon: Icon(
                _passwordShow ? CupertinoIcons.eye : CupertinoIcons.eye_solid,
              ),
              onPressed: changePassState,
            ))
        : AppBar(
            title: Text('Create New Account'),
          );
  }

  Widget getLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Device.get().isIos
                ? CupertinoTextField(
                    controller: _name,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    cursorColor: Theme.of(context).primaryColor,
                    placeholder: 'Name',
                  )
                : TextFormField(
                    controller: _name,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(hintText: 'Name'),
                  ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Device.get().isIos
                ? CupertinoTextField(
                    controller: _email,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    cursorColor: Theme.of(context).primaryColor,
                    placeholder: 'Email',
                  )
                : TextFormField(
                    controller: _email,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(hintText: 'Email'),
                  ),
          ),
          Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    flex: 9,
                    child: Device.get().isIos
                        ? CupertinoTextField(
                            controller: _pass,
                            autofocus: false,
                            obscureText: _passwordShow,
                            clearButtonMode: OverlayVisibilityMode.editing,
                            cursorColor: Theme.of(context).primaryColor,
                            placeholder: 'Password',
                          )
                        : TextFormField(
                            controller: _pass,
                            autofocus: false,
                            obscureText: _passwordShow,
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              hintText: 'Password',
                            ),
                          ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                        icon: Icon(_passwordShow
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: changePassState),
                  )
                ],
              )),
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Text('Gender : ')),
          Container(
            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
            child: Row(
              children: <Widget>[
                Radio(
                    value: Gender.Other,
                    groupValue: _userGender,
                    onChanged: (gender) {
                      setState(() {
                        _userGender = gender;
                      });
                    }),
                Text('Other'),
                Radio(
                    value: Gender.Female,
                    groupValue: _userGender,
                    onChanged: (gender) {
                      setState(() {
                        _userGender = gender;
                      });
                    }),
                Text('Female'),
                Radio(
                    value: Gender.Male,
                    groupValue: _userGender,
                    onChanged: (gender) {
                      setState(() {
                        _userGender = gender;
                      });
                    }),
                Text('Male'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Date Of Birth : '),
                Text(date == null ? 'Not Set' : format.format(date)),
                IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      getDOB(context);
                    })
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
            child: Device.get().isIos
                ? CupertinoButton(child: Text('Submit'), onPressed: () {})
                : RaisedButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      createAccount(context);
                    },
                    color: Theme.of(context).primaryColor,
                  ),
          )
        ],
      ),
    );
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
    return Scaffold(
      appBar: getAppBar(),
      backgroundColor: Colors.white,
      body: getLayout(context),
    );
  }
}

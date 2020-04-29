import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

class CreateAccount extends StatefulWidget {
  static const route = 'create';
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool _passwordShow = true;
  String _dob = '';
  TextEditingController _email = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _pass = TextEditingController();

  void changePassState() {
    setState(() {
      _passwordShow = !_passwordShow;
    });
  }

  void createAccount(){}

  void getDOB(){}

  void getGender(){}

  Widget getAppBar(){
    return Device.get().isIos ? CupertinoNavigationBar(
      middle: Text('Create New Account'),
      trailing: IconButton(icon: Icon(_passwordShow ? CupertinoIcons.eye : CupertinoIcons.eye_solid,), onPressed: changePassState,
    )) : AppBar(
      title: Text('Create New Account'),
      );
  }

  Widget getLayout(BuildContext context){
    return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Device.get().isIos
                  ? CupertinoTextField(
                      autofocus: false,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      cursorColor: Theme.of(context).primaryColor,
                      placeholder: 'Name',
                    )
                  : TextFormField(
                      autofocus: false,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(hintText: 'Name'),
                    ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Device.get().isIos
                  ? CupertinoTextField(
                      autofocus: false,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      cursorColor: Theme.of(context).primaryColor,
                      placeholder: 'Email',
                    )
                  : TextFormField(
                      autofocus: false,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(hintText: 'Email'),
                    ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Device.get().isIos
                  ? CupertinoTextField(
                      autofocus: false,
                      obscureText: _passwordShow,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      cursorColor: Theme.of(context).primaryColor,
                      placeholder: 'Password',
                      decoration: BoxDecoration(),
                    )
                  : TextFormField(
                      autofocus: false,
                      obscureText: _passwordShow,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: Icon(_passwordShow ? Icons.visibility_off : Icons.visibility )),
                          onTap: changePassState,
                    ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Device.get().isIos
                          ? CupertinoTextField(
                              autofocus: false,
                              enabled: false,
                              clearButtonMode: OverlayVisibilityMode.editing,
                              cursorColor: Theme.of(context).primaryColor,
                              placeholder: 'Date Of Birth',
                            )
                          : TextFormField(
                              enabled: false,
                              autofocus: false,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration:
                                  InputDecoration(hintText: 'Date Of Birth'),
                            ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Device.get().isIos
                          ? CupertinoTextField(
                              autofocus: false,
                              enabled: false,
                              clearButtonMode: OverlayVisibilityMode.editing,
                              cursorColor: Theme.of(context).primaryColor,
                              placeholder: 'Gender',
                            )
                          : TextFormField(
                              enabled: false,
                              autofocus: false,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(hintText: 'Gender'),
                            ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Device.get().isIos
                  ? CupertinoButton(child: Text('Submit'), onPressed: () {})
                  : RaisedButton(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {},
                      color: Theme.of(context).primaryColor,
                    ),
            )
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      backgroundColor: Colors.white,
      body: getLayout(context),
    );
  }
}

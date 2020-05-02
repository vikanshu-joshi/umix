import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  ProgressDialog _progressDialog;
  DateFormat dateFormat = DateFormat.yMMMMd();

  @override
  void initState() {
    SplashScreen.mUser.reload();
    super.initState();
  }

  void verifyEmail(BuildContext context) {
    SplashScreen.mUser.sendEmailVerification().then((_) {
      showDialog(
        context: context,
        builder: (_) {
          return Device.get().isIos
              ? CupertinoAlertDialog(
                  title: Text("It's Done"),
                  content: Text('Email verification link sent to ${SplashScreen.myProfile.email}'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text("It's Done"),
                  content: Text('Email verification link sent to ${SplashScreen.myProfile.email}'),
                  elevation: 5.0,
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'))
                  ],
                );
        });
    }).catchError((error) {
      showAlertError(error.message, context);
    });
  }

  void changeDate(BuildContext context) async {
    Device.get().isIos
        ? CupertinoDatePicker(
            maximumDate: DateTime.now(),
            minimumDate: DateTime.utc(1980),
            onDateTimeChanged: (_date) {
              _progressDialog.show();
              Map<String, String> data = {'dob': dateFormat.format(_date)};
              SplashScreen.userRef
                  .document(SplashScreen.mUser.uid)
                  .updateData(data)
                  .then((_) {
                _progressDialog.hide();
                setState(() {
                  SplashScreen.myProfile.dob = dateFormat.format(_date);
                });
              }).catchError((error) {
                _progressDialog.hide();
                showAlertError(error.message, context);
              });
            })
        : DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime.utc(1980),
            theme: DatePickerTheme(
              backgroundColor: Colors.white,
            ),
            maxTime: DateTime.now(), onConfirm: (_date) {
            _progressDialog.show();
            Map<String, String> data = {'dob': dateFormat.format(_date)};
            SplashScreen.userRef
                .document(SplashScreen.mUser.uid)
                .updateData(data)
                .then((_) {
              _progressDialog.hide();
              setState(() {
                SplashScreen.myProfile.dob = dateFormat.format(_date);
              });
            }).catchError((error) {
              _progressDialog.hide();
              showAlertError(error.message, context);
            });
          });
  }

  void changeName(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    showDialog(context: context,builder: (ctx){
      return Device.get().isIos ? CupertinoAlertDialog(
        content: Container(
          child: CupertinoTextField(
            controller: _nameController,
            placeholder: 'Enter Your New Name',
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(child: Text('Cancel'),onPressed: () => Navigator.of(context).pop(),),
          CupertinoDialogAction(child: Text('Ok'),onPressed: () {
            if(_nameController.text.trim().isNotEmpty){
              String newName = _nameController.text.trim();
              _nameController.dispose();
              uploadName(newName,context);
            }
          },),
        ],
      ) : AlertDialog(

        content: Container(
          child: TextField(
            textCapitalization: TextCapitalization.words,
            controller: _nameController,
            decoration: InputDecoration(hintText: 'Enter Your New Name'),
          ),
        ),
        actions: <Widget>[
          FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          FlatButton(onPressed: () {
            if(_nameController.text.trim().isNotEmpty){
              String newName = _nameController.text.trim();
              _nameController.dispose();
              uploadName(newName,context);
            }
          }, child: Text('Ok')),
        ],
      );
    });
  }

  void uploadName(String name,BuildContext context){
    Navigator.of(context).pop();
    _progressDialog.show();
    Map <String,String> data = {'name' : name};
    SplashScreen.userRef.document(SplashScreen.mUser.uid).updateData(data).then((_){
      _progressDialog.hide();
      setState(() {
        SplashScreen.myProfile.name = name;
      });
    });
  }

  void changeGender(BuildContext context) {}

  void logOut(BuildContext context) {
    SplashScreen.mAuth.signOut().then((_) {
      SplashScreen.mUser = null;
      Navigator.of(context).pushReplacementNamed(SplashScreen.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!SplashScreen.mUser.isEmailVerified) {
      SplashScreen.mAuth.currentUser().then((_user) {
        setState(() {
          SplashScreen.mUser = _user;
        });
      });
    }
    var mediaQuery = MediaQuery.of(context).size;
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
    return NestedScrollView(
        headerSliverBuilder: (ctx, scrolled) {
          return [
            SliverAppBar(
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      LineIcons.picture_o,
                      color: Colors.white,
                    ),
                    onPressed: () {})
              ],
              expandedHeight: mediaQuery.height * 0.4,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  SplashScreen.myProfile.name,
                  style: TextStyle(fontFamily: 'Aclonica', color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: SplashScreen.myProfile.image == 'default'
                    ? Image.asset(
                        'assets/images/default.png',
                        fit: BoxFit.cover,
                      )
                    : FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: SplashScreen.myProfile.image,
                        fit: BoxFit.cover,
                      ),
              ),
            )
          ];
        },
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 50),
                child: GestureDetector(
                  onTap: () => verifyEmail(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        SplashScreen.mUser.isEmailVerified
                            ? 'You are a verified user'
                            : 'You need to verify email',
                        style: TextStyle(fontSize: 16),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Icon(
                          SplashScreen.mUser.isEmailVerified
                              ? Icons.thumb_up
                              : Icons.error,
                          color: SplashScreen.mUser.isEmailVerified
                              ? Colors.green
                              : Colors.red,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          SplashScreen.myProfile.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if(SplashScreen.mUser.isEmailVerified){
                                changeName(context);
                              }else{
                                showAlertError('You need to verify email before editing your profile', context);
                              }
                            }),
                      ),
                      ListTile(
                        title: Text(
                          SplashScreen.myProfile.email,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          SplashScreen.myProfile.dob,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              changeDate(context);
                            }),
                      ),
                      ListTile(
                        title: Text(
                          SplashScreen.myProfile.gender,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              changeGender(context);
                            }),
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.05,
                    top: MediaQuery.of(context).size.width * 0.02),
                child: Device.get().isIos
                    ? CupertinoButton(
                        color: Colors.red,
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => logOut(context))
                    : FlatButton(
                        color: Colors.red,
                        onPressed: () => logOut(context),
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
              )
            ],
          ),
        ));
  }
}

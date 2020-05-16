import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/MyProfile/my_friends.dart';
import 'package:umix/screens/MyProfile/my_requests.dart';
import 'package:umix/screens/MyProfile/my_timeline.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  ProgressDialog _progressDialog;
  DateFormat dateFormat = DateFormat.yMMMMd();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    SplashScreen.mUser.reload();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void changeMyDP(BuildContext context) async {
    var result = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (result == null) {
      return;
    }
    try {
      _progressDialog.show();
      var uploaded = SplashScreen.storageReference
          .child('profile_images')
          .child('${SplashScreen.mUser.uid}.jpg');
      uploaded.putFile(result).onComplete.then((onValue) {
        onValue.ref.getDownloadURL().then((uri) {
          Map<String, String> data = {'image': uri.toString()};
          SplashScreen.userRef
              .document(SplashScreen.mUser.uid)
              .updateData(data)
              .then((_) {
            _progressDialog.hide();
            setState(() {
              SplashScreen.myProfile.image = uri.toString();
            });
          }).catchError((error) {
            _progressDialog.hide();
            showAlertError(error.message, context);
          });
        });
      }).catchError((error) {
        _progressDialog.hide();
        showAlertError(error.message, context);
      });
    } catch (error) {
      showAlertError(error.message, context);
    }
  }

  void verifyEmail(BuildContext context) {
    if (SplashScreen.mUser.isEmailVerified) {
      return;
    }
    SplashScreen.mUser.sendEmailVerification().then((_) {
      showDialog(
          context: context,
          builder: (_) {
            return Device.get().isIos
                ? CupertinoAlertDialog(
                    title: Text("It's Done"),
                    content: Text(
                        'Email verification link sent to ${SplashScreen.myProfile.email}'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  )
                : AlertDialog(
                    title: Text("It's Done"),
                    content: Text(
                        'Email verification link sent to ${SplashScreen.myProfile.email}'),
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
    showDialog(
        context: context,
        builder: (ctx) {
          return Device.get().isIos
              ? CupertinoAlertDialog(
                  content: Container(
                    child: CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Enter Your New Name',
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      child: Text('Ok'),
                      onPressed: () {
                        if (_nameController.text.trim().isNotEmpty) {
                          String newName = _nameController.text.trim();
                          uploadName(newName, context);
                        }
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  content: Container(
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: _nameController,
                      decoration:
                          InputDecoration(hintText: 'Enter Your New Name'),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel')),
                    FlatButton(
                        onPressed: () {
                          if (_nameController.text.trim().isNotEmpty) {
                            String newName = _nameController.text.trim();
                            _nameController.dispose();
                            uploadName(newName, context);
                          }
                        },
                        child: Text('Ok')),
                  ],
                );
        });
  }

  void uploadName(String name, BuildContext context) {
    Navigator.of(context).pop();
    _progressDialog.show();
    Map<String, String> data = {'name': name};
    SplashScreen.userRef
        .document(SplashScreen.mUser.uid)
        .updateData(data)
        .then((_) {
      _progressDialog.hide();
      setState(() {
        SplashScreen.myProfile.name = name;
      });
    }).catchError((error) {
      _progressDialog.hide();
      showAlertError(error.message, context);
    });
  }

  void changeGender(BuildContext context) async {
    String chosen;
    if (Device.get().isIos) {
      chosen = await showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return CupertinoActionSheet(
              title: Text('Choose a Gender'),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Other'),
                  child: Text('Other'),
                  isDefaultAction: true,
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Female'),
                  child: Text('Female'),
                  isDefaultAction: true,
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('Male'),
                  child: Text('Male'),
                  isDefaultAction: true,
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop('Cancel'),
                child: Text('Cancel'),
                isDestructiveAction: true,
              ),
            );
          });
    } else {
      chosen = await showModalBottomSheet(
          isDismissible: false,
          context: context,
          builder: (_) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Container(
                    child: FlatButton(
                        onPressed: () => Navigator.of(context).pop('Other'),
                        child: Text(
                          'Other',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        )),
                  ),
                  Divider(),
                  Container(
                    child: FlatButton(
                        onPressed: () => Navigator.of(context).pop('Female'),
                        child: Text(
                          'Female',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        )),
                  ),
                  Divider(),
                  Container(
                    child: FlatButton(
                        onPressed: () => Navigator.of(context).pop('Male'),
                        child: Text(
                          'Male',
                          style: TextStyle(color: Colors.blue, fontSize: 20),
                        )),
                  ),
                  Divider(),
                  Container(
                    child: FlatButton(
                        onPressed: () => Navigator.of(context).pop('Cancel'),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        )),
                  ),
                ],
              ),
            );
          });
    }
    if (chosen != 'Cancel' && chosen != null) {
      _progressDialog.show();
      Map<String, String> data = {'gender': chosen};
      SplashScreen.userRef
          .document(SplashScreen.mUser.uid)
          .updateData(data)
          .then((_) {
        _progressDialog.hide();
        setState(() {
          SplashScreen.myProfile.gender = chosen;
        });
      }).catchError((error) {
        _progressDialog.hide();
        showAlertError(error.message, context);
      });
    }
  }

  void logOut(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(SplashScreen.route);
    SplashScreen.mAuth.signOut();SplashScreen.mUser = null;
    SplashScreen.myProfile = User('', '', '', '', '', '');
  }

  void viewMyPosts() {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return MyTimeLine(SplashScreen.myProfile.uid);
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (SplashScreen.mUser != null && !SplashScreen.mUser.isEmailVerified) {
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
                      Icons.image,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (SplashScreen.mUser.isEmailVerified) {
                        changeMyDP(context);
                      } else {
                        showAlertError(
                            "You need to verify email first", context);
                      }
                    })
              ],
              expandedHeight: mediaQuery.height * 0.4,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: [StretchMode.zoomBackground],
                centerTitle: true,
                title: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    SplashScreen.myProfile.name,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontFamily: 'Aclonica', color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                background: SplashScreen.myProfile.image == 'default'
                    ? Image.asset(
                        'assets/images/default.png',
                      )
                    : Container(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CachedNetworkImage(
                              width: mediaQuery.width,
                              imageUrl: SplashScreen.myProfile.image,
                              fit: BoxFit.fill,
                              placeholder: (ctx, str) => Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: CachedNetworkImage(
                                imageUrl: SplashScreen.myProfile.image,
                                fit: BoxFit.fitHeight,
                                placeholder: (ctx, str) => Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                            )
                          ],
                        ),
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
              Flexible(
                  fit: FlexFit.tight,
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: viewMyPosts,
                            child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(CustomIcons.my_timeline),
                                      Text('My Posts')
                                    ],
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (ctx) {
                                    return MyFriends();
                                  }));
                            },
                            child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(CustomIcons.friends_hands),
                                      Text('Friends')
                                    ],
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (ctx) {
                                    return MyRequests();
                                  }));
                            },
                            child: Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(CustomIcons.send_request),
                                      Text('Requests')
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text(
                          SplashScreen.mUser.isEmailVerified
                              ? 'You are a verified user'
                              : 'You need to verify email',
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              SplashScreen.mUser.isEmailVerified
                                  ? Icons.thumb_up
                                  : Icons.error,
                              color: SplashScreen.mUser.isEmailVerified
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onPressed: () {
                              if (!SplashScreen.mUser.isEmailVerified) {
                                verifyEmail(context);
                              }
                            }),
                      ),
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
                              if (SplashScreen.mUser.isEmailVerified) {
                                changeName(context);
                              } else {
                                showAlertError(
                                    'You need to verify email before editing your profile',
                                    context);
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
                      ListTile(
                        title: Text('Logout'),
                        trailing: IconButton(
                            icon: Icon(
                              LineIcons.power_off,
                              color: Colors.red,
                            ),
                            onPressed: () => logOut(context)),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}

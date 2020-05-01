import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  SharedPreferences _prefs;
  ProgressDialog _progressDialog;
  DateFormat dateFormat = DateFormat.yMMMMd();
  List<String> _myProfileData = [
    'Batman',
    'bruce.wayne@wayne.enterprises.com',
    '',
    'default',
  ];
  String imageUri = 'default';

  Future<bool> getMyProfile() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _myProfileData[0] = _prefs.getString('name');
      _myProfileData[1] = _prefs.getString('email');
      _myProfileData[2] = _prefs.getString('dob');
      _myProfileData[3] = _prefs.getString('gender');
      imageUri = _prefs.getString('image');
    });
    return true;
  }

  @override
  void initState() {
    _myProfileData[2] = dateFormat.format(DateTime.now());
    getMyProfile();
    super.initState();
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
                  _myProfileData[2] = dateFormat.format(_date);
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
                _myProfileData[2] = dateFormat.format(_date);
              });
            }).catchError((error) {
              _progressDialog.hide();
              showAlertError(error.message, context);
            });
          });
  }

  void changeName(BuildContext context) {}

  void changeEmail(BuildContext context) {}

  void changeGender(BuildContext context) {}

  void manageEdit(int index, BuildContext context) {
    if (index == 2) {
      changeDate(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _myProfileData[0],
                  style: TextStyle(fontFamily: 'Aclonica'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: imageUri == 'default'
                    ? Image.asset(
                        'assets/images/default.png',
                        fit: BoxFit.cover,
                      )
                    : FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: imageUri,
                        fit: BoxFit.cover,
                      ),
              ),
            )
          ];
        },
        body: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                      itemCount: _myProfileData.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(
                            _myProfileData[index],
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                manageEdit(index, context);
                              }),
                        );
                      }))
            ],
          ),
        ));
  }
}

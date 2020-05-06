import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

class FinalPostUpload extends StatefulWidget {
  final File image;
  FinalPostUpload(this.image);
  @override
  _FinalPostUploadState createState() => _FinalPostUploadState();
}

class _FinalPostUploadState extends State<FinalPostUpload> {
  TextEditingController _caption;
  TextEditingController _location;
  String _currentLocation;
  ProgressDialog _progressDialog;

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            middle: Text('Enter final details'),
            trailing: IconButton(
              icon: Icon(
                CupertinoIcons.forward,
                color: Colors.black,
              ),
              onPressed: postFinalised,
            ))
        : AppBar(
            leading: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            title: Text('Enter final details'),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.check, color: Colors.black),
                  onPressed: postFinalised)
            ],
          );
  }

  void getLocation() {
    _progressDialog.show();
    final Geolocator locator = Geolocator()..forceAndroidLocationManager;
    locator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((location) {
      locator
          .placemarkFromCoordinates(location.latitude, location.longitude)
          .then((data) {
        Placemark place = data[0];
        _progressDialog.hide();
        setState(() {
          _currentLocation =
              '${place.locality}, ${place.postalCode}, ${place.country}';
          _location.text = _currentLocation;
        });
      });
    }).catchError((error) {
      showAlertError(error.message, context);
    });
  }

  void postFinalised() {
    String caption = _caption.text.trim();
    String location = _location.text.trim();
    if (widget.image == null && caption.isEmpty) {
      Navigator.of(context).pop();
      return;
    } else {
      _progressDialog.show();
      var id = Uuid().v4().toString();
      Post newPost = Post(id, caption, 'null',
          location.isEmpty ? 'null' : location, SplashScreen.mUser.uid, 0);
      if (widget.image != null) {
        var upload =
            SplashScreen.storageReference.child('posts').child(id + '.jpg');
        upload.putFile(widget.image).onComplete.then((status) {
          status.ref.getDownloadURL().then((uri) {
            newPost.image = uri;
            uploadPost(newPost);
          }).catchError((error) {
            _progressDialog.hide();
            showAlertError(error.message, context);
          });
        });
      } else {
        uploadPost(newPost);
      }
    }
  }

  void uploadPost(Post _post) {
    SplashScreen.postRef
        .document(SplashScreen.mUser.uid)
        .collection('userPosts')
        .document(_post.id)
        .setData({
      'id': _post.id,
      'caption': _post.caption,
      'image': _post.image,
      'owner': _post.owner,
      'likes': {},
      'location': _post.location,
      'timestamp': DateTime.now().microsecondsSinceEpoch
    }).then((_) {
      Map<String, String> p = {_post.id: _post.id};
      SplashScreen.userRef
          .document(SplashScreen.mUser.uid)
          .collection('other')
          .document('posts')
          .setData(p)
          .then((_) {
        _progressDialog.hide();
        Navigator.of(context).pop(true);
      }).catchError((error) {
        _progressDialog.hide();
        showAlertError(error.message, context);
      });
    }).catchError((error) {
      _progressDialog.hide();
      showAlertError(error.message, context);
    });
  }

  @override
  void initState() {
    _caption = TextEditingController();
    _location = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _caption.dispose();
    _location.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            widget.image == null
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.all(2),
                    color: Colors.red,
                    child: Container(
                      width: mediaQuery.size.width,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(widget.image),
                              fit: BoxFit.fill)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: ProgressiveImage(
                            fit: BoxFit.contain,
                            placeholder:
                                AssetImage('assets/images/loading.png'),
                            thumbnail: AssetImage('assets/images/loading.png'),
                            image: FileImage(widget.image),
                            width: mediaQuery.size.width,
                            height: mediaQuery.size.height * 0.5),
                      ),
                    ),
                  ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        backgroundImage:
                            NetworkImage(SplashScreen.myProfile.image),
                      ),
                      title: Device.get().isIos
                          ? CupertinoTextField(
                              controller: _caption,
                              placeholder: 'Enter Caption',
                            )
                          : TextField(
                              controller: _caption,
                              decoration:
                                  InputDecoration(hintText: 'Enter Caption'),
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/marker.png'),
                      ),
                      title: Device.get().isIos
                          ? CupertinoTextField(
                              controller: _location,
                              placeholder: 'Enter Location',
                            )
                          : TextField(
                              controller: _location,
                              decoration:
                                  InputDecoration(hintText: 'Enter Location'),
                            ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(30),
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          color: Theme.of(context).primaryColor,
                          onPressed: getLocation,
                          icon: Icon(Icons.my_location),
                          label: Text('Use Current Location')))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

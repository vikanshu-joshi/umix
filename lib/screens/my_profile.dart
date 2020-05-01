import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:umix/screens/splash_screen.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String name = '';
  String email = '';
  String dob = '';
  String image = 'default';
  String gender = '';
  DocumentSnapshot myProfileData;

  void getMyProfile() async {
    myProfileData =
        await SplashScreen.userRef.document(SplashScreen.mUser.uid).get();
    setState(() {
      name = myProfileData['name'];
      email = myProfileData['email'];
      dob = myProfileData['dob'];
      image = myProfileData['image'];
      gender = myProfileData['gender'];
    });
  }

  @override
  void initState() {
    getMyProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
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
                  name,
                  style: TextStyle(fontFamily: 'Aclonica'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: image == 'default'
                    ? Image.asset('assets/images/default.png')
                    : FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage, image: image,fit: BoxFit.cover,),
              ),
            )
          ];
        },
        body: Container());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:umix/screens/my_profile.dart';
import 'package:umix/screens/splash_screen.dart';

class MainScreen extends StatefulWidget {
  static const route = 'main';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FirebaseUser mUser;
  CollectionReference userCollection;
  FirebaseStorage storage;
  PageController _page;
  int _selectedIndex = 0;

  Widget getLayout(BuildContext context) {
    return PageView(
      controller: _page,
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      children: <Widget>[
        Center(
            child: Text(
          '1',
          style: TextStyle(color: Colors.black),
        )),
        Center(
            child: Text(
          '2',
          style: TextStyle(color: Colors.black),
        )),
        Center(
            child: Text(
          '3',
          style: TextStyle(color: Colors.black),
        )),
        MyProfile(),
      ],
    );
  }

  Widget _bottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.5))
              ],
              color: Colors.yellowAccent,
              borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
              gap: Device.get().isTablet ? 8 : 0,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              duration: Duration(milliseconds: 800),
              tabBackgroundColor: Colors.grey[800],
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: Device.get().isTablet ? 'Home' : '',
                ),
                GButton(
                  icon: LineIcons.plus,
                  text: Device.get().isTablet ? 'New' : '',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: Device.get().isTablet ? 'Search' : '',
                ),
                GButton(
                  icon: LineIcons.gear,
                  text: Device.get().isTablet ? 'Settings' : '',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _page.animateToPage(index,
                    duration: Duration(milliseconds: 800), curve: Curves.ease);
              }),
        ),
      ),
    );
  }

  @override
  void initState() {
    mUser = SplashScreen.mUser;
    _page = PageController(
      initialPage: _selectedIndex,
    );
    userCollection = Firestore.instance.collection(mUser.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigation(),
      backgroundColor: Colors.white,
      body: getLayout(context),
    );
  }
}

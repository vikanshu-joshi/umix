import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/screens/MyProfile/my_profile.dart';
import 'package:umix/screens/chat.dart';
import 'package:umix/screens/chat_screen.dart';
import 'package:umix/screens/new_post_screen.dart';
import 'package:umix/screens/search_users.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/screens/timeline_screen.dart';

class MainScreen extends StatefulWidget {
  static const route = 'main';
  static String screen = 'timeline';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FirebaseUser mUser;
  FirebaseStorage storage;
  PageController _page;
  int _selectedIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
        TimeLine(),
        Center(child: ChatScreen()),
        NewPost(),
        SearchUsers(),
        MyProfile(),
      ],
    );
  }

  Widget _bottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.5))
          ], color: Colors.amber, borderRadius: BorderRadius.circular(100)),
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
                  icon: CustomIcons.tmeline,
                  text: Device.get().isTablet ? 'Home' : '',
                ),
                GButton(
                  icon: CustomIcons.comment,
                  text: Device.get().isTablet ? 'Chats' : '',
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

  void configurePushNotifications() {
    if (Device.get().isIos)
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings(alert: true));
    _firebaseMessaging.getToken().then((value) {
      Firestore.instance
          .collection('users')
          .document(mUser.uid)
          .updateData({'androidNotificationToken': value});
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(MainScreen.screen);
        if (MainScreen.screen != 'chat') {
          showSimpleNotification(
              Container(
                child: Text(message['notification']['title'].toString()),
                padding: const EdgeInsets.all(5),
              ),
              elevation: 5.0,
              contentPadding: const EdgeInsets.all(10),
              autoDismiss: true,
              slideDismiss: true,
              trailing: FlatButton(
                child: Text('OPEN'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return Chat(message['data']['name'],
                        message['data']['image'], message['data']['id']);
                  }));
                },
              ),
              subtitle: Container(
                child: Text(message['data']['data'].toString()),
                padding: const EdgeInsets.all(5),
              ),
              background: Colors.white);
        }
      },
    );
  }

  @override
  void initState() {
    mUser = SplashScreen.mUser;
    _page = PageController(
      initialPage: _selectedIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    configurePushNotifications();
    return Scaffold(
      bottomNavigationBar: _bottomNavigation(),
      backgroundColor: Colors.white,
      body: getLayout(context),
    );
  }
}

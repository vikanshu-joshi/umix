import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

class MyFriends extends StatefulWidget {
  final String title;
  MyFriends(this.title);
  @override
  _MyFriendsState createState() => _MyFriendsState();
}



class _MyFriendsState extends State<MyFriends> {

  Widget getAppBar(){
    return Device.get().isIos ? CupertinoNavigationBar() : AppBar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
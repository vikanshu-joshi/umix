import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:umix/screens/splash_screen.dart';

class MyFriends extends StatefulWidget {
  @override
  _MyFriendsState createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  Widget getAppBar() {
    return Device.get().isIos ? CupertinoNavigationBar() : AppBar();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat.yMMMMEEEEd();
    DateFormat formatTime = DateFormat.Hm();
    return Scaffold(
      appBar: Device.get().isIos
          ? CupertinoNavigationBar(
              middle: Text('Friends'),
            )
          : AppBar(
              title: Text('Friends'),
            ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(SplashScreen.myProfile.uid)
              .collection('friends')
              .snapshots(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text('Loading.............'),
              );
            }
            List<String> friends = [];
            List<DocumentSnapshot> data = snapshot.data.documents;
            data.forEach((element) {
              friends.add(element.documentID);
            });
            if(friends.isEmpty){
              return Center(child: Text('You Have No Friends'),);
            }
            return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (ctx, index) {
                  var file = snapshot.data.documents[index];
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: file.data[friends[index]]['image'] ==
                                'default'
                            ? AssetImage('assets/images/default.png')
                            : NetworkImage(file.data[friends[index]]['image']),
                      ),
                      title: Text(file.data[friends[index]]['name']),
                      subtitle: Text(
                        format.format(DateTime.fromMillisecondsSinceEpoch(
                                int.parse(
                                    file.data[friends[index]]['timestamp']))) + ' ' +
                            formatTime.format(DateTime.fromMillisecondsSinceEpoch(
                                int.parse(
                                    file.data[friends[index]]['timestamp']))),
                      ));
                });
          }),
    );
  }
}

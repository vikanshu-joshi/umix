import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/screens/MyProfile/requested.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/screens/user_profile.dart';

class MyRequests extends StatefulWidget {
  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  void showRequested() {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return Requested();
        }));
  }

  void showUser(String uid) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return UserProfile(uid);
        }));
  }

  void acceptRequest(String id, String myId, String name, String image) {
    Firestore.instance
        .collection('users')
        .document(SplashScreen.myProfile.uid)
        .collection('requests')
        .document(id)
        .delete();
    Firestore.instance
        .collection('users')
        .document(id)
        .collection('requested')
        .document(myId)
        .delete();
    CollectionReference myRefFriends = Firestore.instance
        .collection('users')
        .document(myId)
        .collection('friends');
    CollectionReference otherRefFriends = Firestore.instance
        .collection('users')
        .document(id)
        .collection('friends');
    myRefFriends.document(id).setData({
      id: {
        'id': id,
        'name': name,
        'image': image,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      }
    });
    otherRefFriends.document(SplashScreen.myProfile.uid).setData({
      myId: {
        'id': myId,
        'name': SplashScreen.myProfile.name,
        'image': SplashScreen.myProfile.image,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat.yMMMMEEEEd();
    DateFormat formatTime = DateFormat.Hm();
    return Scaffold(
      appBar: Device.get().isIos
          ? CupertinoNavigationBar(
              middle: Text('Friend Requests'),
            )
          : AppBar(
              title: Text('Friend Requests'),
            ),
      body: Column(
        children: <Widget>[
          GestureDetector(
            onTap: showRequested,
            child: Container(
              color: Colors.grey.withOpacity(0.2),
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Friend Requests Sent',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      icon: Icon(CupertinoIcons.forward),
                      onPressed: showRequested)
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .document(SplashScreen.myProfile.uid)
                    .collection('requests')
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text('Loading.............'),
                    );
                  }
                  List<String> requests = [];
                  List<DocumentSnapshot> data = snapshot.data.documents;
                  data.forEach((element) {
                    requests.add(element.documentID);
                  });
                  if (requests.isEmpty) {
                    return Center(
                      child: Text('You have no requests at the moment'),
                    );
                  }
                  return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (ctx, index) {
                        var file = snapshot.data.documents[index];
                        return GestureDetector(
                          onTap: () => showUser(file.data['id']),
                          child: ListTile(
                              trailing: IconButton(
                                  icon: Icon(
                                    CustomIcons.send_request,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    acceptRequest(
                                        file.data['id'],
                                        SplashScreen.myProfile.uid,
                                        file.data['name'],
                                        file.data['image']);
                                  }),
                              leading: CircleAvatar(
                                backgroundImage: file.data['image'] == 'default'
                                    ? AssetImage('assets/images/default.png')
                                    : NetworkImage(file.data['image']),
                              ),
                              title: Text(
                                file.data['name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                format.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(
                                                file.data['timestamp']))) +
                                    ' ' +
                                    formatTime.format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(file.data['timestamp']))),
                              )),
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}

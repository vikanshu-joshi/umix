import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/screens/user_profile.dart';

class Requested extends StatefulWidget {
  @override
  _RequestedState createState() => _RequestedState();
}

class _RequestedState extends State<Requested> {
  void showUser(String uid) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return UserProfile(uid);
        }));
  }

  void deleteRequest(String sendingTO,String sendingFROM){
    CollectionReference myRefRequested =
        Firestore.instance.collection('users').document(sendingFROM).collection('requested');
    CollectionReference otherRefRequests =
        Firestore.instance.collection('users').document(sendingTO).collection('requests');
    myRefRequested.document(sendingTO).delete();
    otherRefRequests.document(sendingFROM).delete();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat.yMMMMEEEEd();
    DateFormat formatTime = DateFormat.Hm();
    return Scaffold(
      appBar: Device.get().isIos
          ? CupertinoNavigationBar(
              middle: Text('Friend Requests Sent'),
            )
          : AppBar(
              title: Text('Friend Requests Sent'),
            ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(SplashScreen.myProfile.uid)
              .collection('requested')
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
                child: Text("You didn't send any friends requests"),
              );
            }
            return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (ctx, index) {
                  print(snapshot.data.documents[index].data['name']);
                  var file = snapshot.data.documents[index];
                  return GestureDetector(
                    onTap: () => showUser(file.data['id'].toString()),
                    child: ListTile(
                      trailing: IconButton(icon: Icon(Icons.delete,color: Colors.red,), onPressed: (){
                        deleteRequest(file.data['id'], SplashScreen.myProfile.uid);
                      }),
                        leading: CircleAvatar(
                          backgroundImage: file.data['image'] == 'default'
                              ? AssetImage('assets/images/default.png')
                              : NetworkImage(file.data['image']),
                        ),
                        title: Text(file.data['name'],overflow: TextOverflow.ellipsis,),
                        subtitle: Text(
                          format.format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(file.data['timestamp']))) +
                              ' ' +
                              formatTime.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(file.data['timestamp']))),
                        )),
                  );
                });
          }),
    );
  }
}

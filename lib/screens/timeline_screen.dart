import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/comment_screen.dart';
import 'package:umix/screens/splash_screen.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  void like(LinkedHashMap data) {
    LinkedHashMap likes = data['likes'];
    if (likes.containsKey(SplashScreen.mUser.uid)) {
      likes.remove(SplashScreen.mUser.uid);
    } else {
      likes[SplashScreen.mUser.uid] = {
        'id': SplashScreen.mUser.uid,
        'name': SplashScreen.myProfile.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      };
    }
    Firestore.instance
        .collection('users')
        .document(SplashScreen.mUser.uid)
        .collection('timeline')
        .document(data['id'].toString())
        .updateData({'likes': likes});
    Firestore.instance
        .collection('posts')
        .document(data['owner'].toString())
        .collection('userPosts')
        .document(data['id'].toString())
        .updateData({'likes': likes});
  }

  void dislike(LinkedHashMap data) {
    LinkedHashMap dislikes = data['dislikes'];
    if (dislikes.containsKey(SplashScreen.mUser.uid)) {
      dislikes.remove(SplashScreen.mUser.uid);
    } else {
      dislikes[SplashScreen.mUser.uid] = {
        'id': SplashScreen.mUser.uid,
        'name': SplashScreen.myProfile.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      };
    }
    Firestore.instance
        .collection('users')
        .document(SplashScreen.mUser.uid)
        .collection('timeline')
        .document(data['id'].toString())
        .updateData({'dislikes': dislikes});
    Firestore.instance
        .collection('posts')
        .document(data['owner'].toString())
        .collection('userPosts')
        .document(data['id'].toString())
        .updateData({'dislikes': dislikes});
  }

  void comment(LinkedHashMap data) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return CommentsScreen(
          Post(
              data['id'],
              data['caption'],
              data['image'],
              data['location'],
              data['owner'],
              data['likes'],
              data['dislikes'],
              data['timestamp'],
              data['comments']),
          SplashScreen.mUser.uid);
    }));
  }

  Widget getPostWidget(LinkedHashMap<String, dynamic> data) {
    print(data);
    return Card(
      elevation: 1.0,
      shape: Border.all(width: 1.0, color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: ListTile(
              subtitle: Text(
                timeago.format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(data['timestamp'].toString()))),
                style: TextStyle(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 30,
                child: CircleAvatar(
                  radius: 27,
                  backgroundImage: data['ownerImage'] == 'default'
                      ? AssetImage('assets/images/default.png')
                      : NetworkImage(data['ownerImage'].toString()),
                ),
              ),
              title: Text(
                data['ownerName'].toString(),
                style: TextStyle(fontFamily: 'Aclonica'),
              ),
            ),
          ),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            placeholder: (ctx, str) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            },
            imageUrl: data['image'].toString(),
            fit: BoxFit.fill,
            alignment: Alignment.center,
          ),
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton.icon(
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () => like(data),
                    icon: Icon(
                      data['likes'].containsKey(SplashScreen.mUser.uid)
                          ? CustomIcons.thumbs_up_filled
                          : CustomIcons.thumbs_up,
                      color: data['likes'].containsKey(SplashScreen.mUser.uid)
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                    label: Text(data['likes'].length.toString())),
                FlatButton.icon(
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () => dislike(data),
                    icon: Icon(
                      data['dislikes'].containsKey(SplashScreen.mUser.uid)
                          ? CustomIcons.thumbs_down_filled
                          : CustomIcons.thumbs_down,
                      color:
                          data['dislikes'].containsKey(SplashScreen.mUser.uid)
                              ? Colors.red
                              : Colors.black,
                    ),
                    label: Text(data['dislikes'].length.toString())),
                FlatButton.icon(
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () => comment(data),
                    icon: Icon(CustomIcons.comment),
                    label: Text(data['comments'].length.toString())),
                FlatButton.icon(
                    onPressed: () => comment(data),
                    icon: Icon(CustomIcons.share_bold),
                    label: Text('0')),
              ],
            ),
          ),
          data['caption'].toString() == 'null' ||
                  data['caption'].toString().isEmpty
              ? SizedBox(
                  height: 0,
                )
              : Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(left: 5, right: 10),
                          child: Icon(
                            Icons.closed_caption,
                            color: Colors.black.withOpacity(0.5),
                            size: 22,
                          )),
                      Text(
                        data['caption'].toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
          data['location'].toString() == 'null'
              ? SizedBox(
                  height: 0,
                )
              : Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(left: 5, right: 10),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.5),
                            size: 22,
                          )),
                      Text(
                        data['location'].toString(),
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(SplashScreen.mUser.uid)
              .collection('timeline')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text('Loading.......'),
              );
            }
            List<DocumentSnapshot> data = snapshot.data.documents.toList();
            if (data.length == 0) {
              return Center(
                child: Text('No Posts to show'),
              );
            }
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (ctx, index) {
                  return getPostWidget(data[index].data);
                });
          }),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/models/data.dart';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyComments extends StatefulWidget {
  final Post post;
  MyComments(this.post);
  @override
  _MyCommentsState createState() => _MyCommentsState();
}

class _MyCommentsState extends State<MyComments> {
  Widget getLayout() {
    LinkedHashMap ds;
    return StreamBuilder(
        stream: Firestore.instance
            .collection('posts')
            .document(widget.post.owner)
            .collection('userPosts')
            .document(widget.post.id)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('Loading....'));
          } else {
            ds = snapshot.data['comments'];
            List<String> keys = [];
            ds.forEach((key, value) {
              keys.add(key.toString());
            });
            return ListView.builder(
                itemCount: keys.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: ds[keys[index]]['image'] == 'default'
                          ? AssetImage('assets/images/default.png')
                          : NetworkImage(ds[keys[index]]['image']),
                    ),
                    title: Text(ds[keys[index]]['comment']),
                    subtitle: Text(timeago
                        .format(DateTime.fromMillisecondsSinceEpoch(
                            int.parse(ds[keys[index]]['timestamp'].toString())))
                        .toString()),
                  );
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Device.get().isIos
          ? CupertinoNavigationBar(
              middle: Text('Comments'),
            )
          : AppBar(
              title: Text('Comments'),
            ),
      body: getLayout(),
    );
  }
}

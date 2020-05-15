import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/models/data.dart';
import 'package:timeago/timeago.dart' as timeago;

class LikesDislikes extends StatefulWidget {
  final String title;
  final Post post;
  LikesDislikes(this.title,this.post);
  @override
  _LikesDislikesState createState() => _LikesDislikesState();
}

class _LikesDislikesState extends State<LikesDislikes> {
  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            middle: Text(widget.title),
          )
        : AppBar(
            title: Text(widget.title),
          );
  }

  Widget getLayout(){
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
                      ds = snapshot.data[widget.title];
                      List<String> keys = [];
                      ds.forEach((key, value) {
                        keys.add(key.toString());
                      });
                      return ListView.builder(
                          itemCount: keys.length,
                          itemBuilder: (ctx, index) {
                            return ListTile(
                              title: Text(ds[keys[index]]['name']),
                              subtitle: Text(timeago
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(ds[keys[index]]['timestamp']
                                          .toString())))
                                  .toString()),
                            );
                          });
                    }
                  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getLayout(),
    );
  }
}

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:umix/models/data.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final String myUID;
  CommentsScreen(this.post, this.myUID);
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _comment;
  @override
  void initState() {
    _comment = TextEditingController();
    super.initState();
  }

  void addComment(LinkedHashMap comments) {
    if (_comment.text.trim().isNotEmpty) {
      if (comments == null) {
        SplashScreen.postRef
            .document(widget.post.owner)
            .collection('userPosts')
            .document(widget.post.id)
            .updateData({
          'comments': {
            widget.myUID: {
              'comment': _comment.text.trim(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'name': SplashScreen.myProfile.name,
              'image': SplashScreen.myProfile.image
            }
          }
        }).then((_) {
          _comment.text = '';
        }).catchError((error) {
          showAlertError(error.toString(), context);
        });
      } else {
        comments[widget.myUID] = {
          'comment': _comment.text.trim(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'name': SplashScreen.myProfile.name,
          'image': SplashScreen.myProfile.image
        };
        SplashScreen.postRef
            .document(widget.post.owner)
            .collection('userPosts')
            .document(widget.post.id)
            .updateData({'comments': comments}).then((_) {
          _comment.text = '';
        }).catchError((error) {
          showAlertError(error.toString(), context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LinkedHashMap ds;
    return Scaffold(
      appBar: Device.get().isIos
          ? CupertinoNavigationBar(
              leading: IconButton(
                  icon: Icon(CupertinoIcons.back),
                  onPressed: () => Navigator.of(context).pop(null)),
              middle: Text('Comments'),
            )
          : AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(null)),
              title: Text('Comments'),
            ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder(
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
                                backgroundImage: ds[keys[index]]['image'] ==
                                        'default'
                                    ? AssetImage('assets/images/default.png')
                                    : NetworkImage(ds[keys[index]]['image']),
                              ),
                              title: Text(ds[keys[index]]['comment']),
                              subtitle: Text(timeago
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(ds[keys[index]]['timestamp']
                                          .toString())))
                                  .toString()),
                            );
                          });
                    }
                  })),
          Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 20, right: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Device.get().isIos
                          ? CupertinoTextField(
                              controller: _comment,
                              placeholder: 'Enter Comment',
                            )
                          : TextField(
                              controller: _comment,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter Comment'),
                            )),
                  IconButton(
                      icon: Icon(LineIcons.share),
                      onPressed: () {
                        addComment(ds);
                      })
                ],
              ))
        ],
      ),
    );
  }
}

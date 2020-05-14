import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/screens/splash_screen.dart';
import 'dart:ui';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyTimeLine extends StatefulWidget {
  final String uid;
  MyTimeLine(this.uid);
  @override
  _MyTimeLineState createState() => _MyTimeLineState();
}

class _MyTimeLineState extends State<MyTimeLine> {

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            middle: Text('My Posts'),
          )
        : AppBar(
            title: Text('My Posts'),
          );
  }

  Widget getLayout() {
    return Container(
      child: StreamBuilder(
          stream: SplashScreen.postRef
              .document(widget.uid)
              .collection('userPosts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text('Loading.......'),
              );
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("You don't have any posts"),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (ctx, index) {
                      return Card(
                        elevation: 1.0,
                        shape: Border.all(width: 1.0, color: Colors.black),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                              imageUrl: snapshot
                                  .data.documents[index].data['image']
                                  .toString(),
                              fit: BoxFit.fill,
                              alignment: Alignment.center,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FlatButton.icon(
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onPressed: () {},
                                      icon: Icon(
                                        snapshot.data.documents[index]
                                                .data['likes']
                                                .containsKey(
                                                    SplashScreen.myProfile.uid)
                                            ? CustomIcons.thumbs_up_filled
                                            : CustomIcons.thumbs_up,
                                        color: snapshot.data.documents[index]
                                                .data['likes']
                                                .containsKey(
                                                    SplashScreen.myProfile.uid)
                                            ? Theme.of(context).primaryColor
                                            : Colors.black,
                                      ),
                                      label: Text(snapshot.data.documents[index]
                                          .data['likes'].length
                                          .toString())),
                                  FlatButton.icon(
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onPressed: () {},
                                      icon: Icon(
                                        snapshot.data.documents[index]
                                                .data['dislikes']
                                                .containsKey(
                                                    SplashScreen.myProfile.uid)
                                            ? CustomIcons.thumbs_down_filled
                                            : CustomIcons.thumbs_down,
                                        color: snapshot.data.documents[index]
                                                .data['dislikes']
                                                .containsKey(
                                                    SplashScreen.myProfile.uid)
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      label: Text(snapshot.data.documents[index]
                                          .data['dislikes'].length
                                          .toString())),
                                  FlatButton.icon(
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onPressed: () {},
                                      icon: Icon(CustomIcons.comment),
                                      label: Text(snapshot.data.documents[index]
                                          .data['comments'].length
                                          .toString())),
                                  FlatButton.icon(
                                      onPressed: () {},
                                      icon: Icon(CustomIcons.share_bold),
                                      label: Text('0')),
                                ],
                              ),
                            ),
                            snapshot.data.documents[index].data['caption']
                                            .toString() ==
                                        'null' ||
                                    snapshot
                                        .data.documents[index].data['caption']
                                        .toString()
                                        .isEmpty
                                ? SizedBox(
                                    height: 0,
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      snapshot
                                          .data.documents[index].data['caption']
                                          .toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                            snapshot.data.documents[index].data['location']
                                        .toString() ==
                                    'null'
                                ? SizedBox(
                                    height: 0,
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      snapshot.data.documents[index]
                                          .data['location']
                                          .toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                timeago.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(snapshot.data.documents[index]
                                            .data['timestamp']
                                            .toString()))),
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        ),
                      );
                    });
              }
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getLayout(),
    );
  }
}

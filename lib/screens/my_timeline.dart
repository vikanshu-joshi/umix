import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';
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
  User _currentUser;

  @override
  void initState() {
    SplashScreen.userRef.document(widget.uid).get().then((user) {
      setState(() {
        _currentUser = User(
            user.data['name'],
            user.data['email'],
            user.data['dob'],
            user.data['gender'],
            user.data['image'],
            user.data['uid']);
      });
    }).catchError((error) {
      showAlertError(error.toString(), context);
    });
    super.initState();
  }

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            middle: _currentUser == null
                ? Text('loading...')
                : Text(_currentUser.name),
          )
        : AppBar(
            title: _currentUser == null
                ? Text('loading...')
                : Text(_currentUser.uid),
          );
  }

  Widget getLayout(){
    return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: MediaQuery.of(context).size.width * 0.1 + 1,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundImage: _currentUser == null
                          ? AssetImage('assets/images/loading.png')
                          : _currentUser.image == 'default'
                              ? AssetImage('assets/images/default.png')
                              : NetworkImage(_currentUser.image),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    _currentUser == null ? 'loading...' : _currentUser.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Aclonica',
                        fontSize: 25),
                  ),
                )
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            Expanded(
              child: Container(
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
                                  shape: Border.all(
                                      width: 1.0, color: Colors.black),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CachedNetworkImage(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width,
                                        placeholder: (ctx, str) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child:
                                                  CupertinoActivityIndicator(),
                                            ),
                                          );
                                        },
                                        imageUrl: snapshot.data
                                            .documents[index].data['image']
                                            .toString(),
                                        fit: BoxFit.fill,
                                        alignment: Alignment.center,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            FlatButton.icon(
                                                hoverColor:
                                                    Colors.transparent,
                                                focusColor:
                                                    Colors.transparent,
                                                splashColor:
                                                    Colors.transparent,
                                                onPressed: (){},
                                                icon: Icon(
                                                  snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['likes']
                                                          .containsKey(
                                                              SplashScreen
                                                                  .myProfile
                                                                  .uid)
                                                      ? CustomIcons
                                                          .thumbs_up_filled
                                                      : CustomIcons
                                                          .thumbs_up,
                                                  color: snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['likes']
                                                          .containsKey(
                                                              SplashScreen
                                                                  .myProfile
                                                                  .uid)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.black,
                                                ),
                                                label: Text(snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['likes']
                                                    .length
                                                    .toString())),
                                            FlatButton.icon(
                                                hoverColor:
                                                    Colors.transparent,
                                                focusColor:
                                                    Colors.transparent,
                                                splashColor:
                                                    Colors.transparent,
                                                onPressed: (){},
                                                icon: Icon(
                                                  snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['dislikes']
                                                          .containsKey(
                                                              SplashScreen
                                                                  .myProfile
                                                                  .uid)
                                                      ? CustomIcons
                                                          .thumbs_down_filled
                                                      : CustomIcons
                                                          .thumbs_down,
                                                  color: snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['dislikes']
                                                          .containsKey(
                                                              SplashScreen
                                                                  .myProfile
                                                                  .uid)
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                                label: Text(snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['dislikes']
                                                    .length
                                                    .toString())),
                                            FlatButton.icon(
                                                hoverColor:
                                                    Colors.transparent,
                                                focusColor:
                                                    Colors.transparent,
                                                splashColor:
                                                    Colors.transparent,
                                                onPressed: (){},
                                                icon: Icon(
                                                    CustomIcons.comment),
                                                label: Text(snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['comments']
                                                    .length
                                                    .toString())),
                                            FlatButton.icon(
                                                onPressed: () {},
                                                icon: Icon(
                                                    CustomIcons.share_bold),
                                                label: Text('0')),
                                          ],
                                        ),
                                      ),
                                      snapshot.data.documents[index]
                                                      .data['caption']
                                                      .toString() ==
                                                  'null' ||
                                              snapshot.data.documents[index]
                                                  .data['caption']
                                                  .toString()
                                                  .isEmpty
                                          ? SizedBox(
                                              height: 0,
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(10),
                                              child: Text(
                                                snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['caption']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                      snapshot.data.documents[index]
                                                  .data['location']
                                                  .toString() ==
                                              'null'
                                          ? SizedBox(
                                              height: 0,
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(10),
                                              child: Text(
                                                snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['location']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          timeago.format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['timestamp']
                                                      .toString()))),
                                          style: TextStyle(
                                              color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                      }
                    }),
              ),
            )
          ],
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
import 'dart:collection';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/comment_screen.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserProfile extends StatefulWidget {
  final String uid;
  UserProfile(this.uid);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var device = Device.get().isIos;
  User _currentUser;
  String isFriend = 'none';
  CollectionReference users = Firestore.instance.collection('users');

  void like(DocumentSnapshot snapshot, String myID) {
    LinkedHashMap likes = snapshot.data['likes'];
    String pid = snapshot.data['id'].toString();
    String owner = snapshot.data['owner'].toString();
    if (likes.length == 0 || !likes.containsKey(myID)) {
      likes[myID] = {
        'name': SplashScreen.myProfile.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'id': myID
      };
    } else {
      likes.remove(myID);
    }
    SplashScreen.postRef
        .document(owner)
        .collection('userPosts')
        .document(pid)
        .updateData({'likes': likes});
  }

  void dislike(DocumentSnapshot snapshot, String myID) {
    LinkedHashMap dislikes = snapshot.data['dislikes'];
    String pid = snapshot.data['id'].toString();
    String owner = snapshot.data['owner'].toString();
    if (dislikes.length == 0 || !dislikes.containsKey(myID)) {
      dislikes[myID] = {
        'name': SplashScreen.myProfile.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'id': myID
      };
    } else {
      dislikes.remove(myID);
    }
    SplashScreen.postRef
        .document(owner)
        .collection('userPosts')
        .document(pid)
        .updateData({'dislikes': dislikes});
  }

  void comment(DocumentSnapshot snapshot, String myId) {
    String id = snapshot.data['id'].toString();
    String owner = snapshot.data['owner'].toString();
    String caption = snapshot.data['caption'].toString();
    String image = snapshot.data['image'].toString();
    String location = snapshot.data['location'].toString();
    int timestamp = int.parse(snapshot.data['timestamp'].toString());
    LinkedHashMap<dynamic, dynamic> likes = snapshot.data['likes'];
    LinkedHashMap<dynamic, dynamic> dislikes = snapshot.data['dislikes'];
    LinkedHashMap<dynamic, dynamic> comments = snapshot.data['comments'];
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return CommentsScreen(
          Post(id, caption, image, location, owner, likes, dislikes, timestamp,
              comments),
          myId);
    }));
  }

  void sendRequest() async {
    String sendingTO = _currentUser.uid;
    String sendingFROM = SplashScreen.myProfile.uid;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    CollectionReference myRefRequested =
        users.document(sendingFROM).collection('requested');
    CollectionReference otherRefRequests =
        users.document(sendingTO).collection('requests');
    if (isFriend == 'none') {
      myRefRequested.document(sendingTO).setData({
        'id': sendingTO,
        'name': _currentUser.name,
        'image': _currentUser.image,
        'timestamp': timestamp
      });
      otherRefRequests.document(sendingFROM).setData({
        'id': sendingFROM,
        'name': SplashScreen.myProfile.name,
        'image': SplashScreen.myProfile.image,
        'timestamp': timestamp
      });
      setState(() {
        isFriend = 'waiting';
      });
    } else if (isFriend == 'waiting') {
      myRefRequested.document(sendingTO).delete();
      otherRefRequests.document(sendingFROM).delete();
      setState(() {
        isFriend = 'none';
      });
    } else if (isFriend == 'respond') {
      users
          .document(SplashScreen.myProfile.uid)
          .collection('requests')
          .document(sendingTO)
          .delete();
      users
          .document(_currentUser.uid)
          .collection('requested')
          .document(sendingFROM)
          .delete();
      CollectionReference myRefFriends =
          users.document(sendingFROM).collection('friends');
      CollectionReference otherRefFriends =
          users.document(sendingTO).collection('friends');
      myRefFriends.document(_currentUser.uid).setData({
        _currentUser.uid: {
          'id': sendingTO,
          'name': _currentUser.name,
          'image': _currentUser.image,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
        }
      });
      otherRefFriends.document(SplashScreen.myProfile.uid).setData({
        SplashScreen.myProfile.uid: {
          'id': sendingFROM,
          'name': SplashScreen.myProfile.name,
          'image': SplashScreen.myProfile.image,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
        }
      });
      setState(() {
        isFriend = 'friend';
      });
    }
  }

  Widget getAppBar() {
    return device
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
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    isFriend == 'none'
                        ? CustomIcons.send_request
                        : isFriend == 'waiting'
                            ? CustomIcons.request_waiting
                            : isFriend == 'friend'
                                ? CustomIcons.friends
                                : CustomIcons.send_request,
                    color: isFriend == 'none'
                        ? Colors.white
                        : isFriend == 'waiting'
                            ? Colors.orange
                            : isFriend == 'friend'
                                ? Colors.green
                                : Colors.white,
                  ),
                  onPressed: sendRequest)
            ],
          );
  }

  Widget getLayout() {
    return Column(
      children: <Widget>[
        isFriend == 'respond'
            ? Container(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Want To Accept Request ?'),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.done,
                        color: Colors.green,
                      ),
                      onPressed: sendRequest),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
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
            Expanded(
              child: Container(
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
              ),
            ),
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
                        child: Text('User Has No Posts'),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (ctx, index) {
                            return Card(
                              elevation: 1.0,
                              shape:
                                  Border.all(width: 1.0, color: Colors.black),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CachedNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    placeholder: (ctx, str) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width,
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
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        FlatButton.icon(
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onPressed: () => like(
                                                snapshot.data.documents[index],
                                                SplashScreen.myProfile.uid),
                                            icon: Icon(
                                              snapshot.data.documents[index]
                                                      .data['likes']
                                                      .containsKey(SplashScreen
                                                          .myProfile.uid)
                                                  ? CustomIcons.thumbs_up_filled
                                                  : CustomIcons.thumbs_up,
                                              color: snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['likes']
                                                      .containsKey(SplashScreen
                                                          .myProfile.uid)
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
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onPressed: () => dislike(
                                                snapshot.data.documents[index],
                                                SplashScreen.myProfile.uid),
                                            icon: Icon(
                                              snapshot.data.documents[index]
                                                      .data['dislikes']
                                                      .containsKey(SplashScreen
                                                          .myProfile.uid)
                                                  ? CustomIcons
                                                      .thumbs_down_filled
                                                  : CustomIcons.thumbs_down,
                                              color: snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['dislikes']
                                                      .containsKey(SplashScreen
                                                          .myProfile.uid)
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
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            onPressed: () => comment(
                                                snapshot.data.documents[index],
                                                SplashScreen.myProfile.uid),
                                            icon: Icon(CustomIcons.comment),
                                            label: Text(snapshot
                                                .data
                                                .documents[index]
                                                .data['comments']
                                                .length
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
                                          snapshot.data.documents[index]
                                              .data['caption']
                                              .toString()
                                              .isEmpty
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5, right: 10),
                                                  child: Icon(
                                                    Icons.closed_caption,
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    size: 22,
                                                  )),
                                              Text(
                                                snapshot.data.documents[index]
                                                    .data['caption']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
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
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5, right: 10),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    size: 22,
                                                  )),
                                              Text(
                                                snapshot.data.documents[index]
                                                    .data['location']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 5, right: 10),
                                            child: Icon(
                                              Icons.access_alarm,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              size: 22,
                                            )),
                                        Text(
                                          timeago.format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['timestamp']
                                                      .toString()))),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
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

  void setFriendStatus() async {
    var data = await users
        .document(SplashScreen.myProfile.uid)
        .collection('requested')
        .document(_currentUser.uid)
        .get();
    if (data.exists) {
      setState(() {
        isFriend = 'waiting';
      });
      return;
    }
    data = await users
        .document(SplashScreen.myProfile.uid)
        .collection('requests')
        .document(_currentUser.uid)
        .get();
    if (data.exists) {
      setState(() {
        isFriend = 'respond';
      });
      return;
    }
    data = await users
        .document(SplashScreen.myProfile.uid)
        .collection('friends')
        .document(_currentUser.uid)
        .get();
    if (data.exists) {
      setState(() {
        isFriend = 'friend';
      });
      return;
    }
    isFriend = 'none';
  }

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
      setFriendStatus();
    }).catchError((error) {
      showAlertError(error.toString(), context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getLayout(),
    );
  }
}

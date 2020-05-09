import 'dart:collection';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/comment_screen.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:umix/widgets/common_widgets.dart';

class UserProfile extends StatefulWidget {
  final String uid;
  UserProfile(this.uid);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var device = Device.get().isIos;
  User _currentUser;
  List<Post> _postsList;

  void like(int index, String myID) {
    if (_postsList[index].likes.containsKey(myID)) {
      _postsList[index].likes.remove(myID);
    } else {
      _postsList[index].likes[myID] = myID;
    }
    setState(() {});
    SplashScreen.postRef
        .document(_postsList[index].owner)
        .collection('userPosts')
        .document(_postsList[index].id)
        .updateData({'likes': _postsList[index].likes}).catchError((error) {
      showAlertError(error.toString(), context);
    });
  }

  void dislike(int index, String myID) {
    if (_postsList[index].dislikes.containsKey(myID)) {
      _postsList[index].dislikes.remove(myID);
    } else {
      _postsList[index].dislikes[myID] = myID;
    }
    setState(() {});
    SplashScreen.postRef
        .document(_postsList[index].owner)
        .collection('userPosts')
        .document(_postsList[index].id)
        .updateData({'dislikes': _postsList[index].dislikes}).catchError(
            (error) {
      showAlertError(error.toString(), context);
    });
  }

  void comment(int index, String myId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
      return CommentsScreen(_postsList[index],myId);
    }));
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
          );
  }

  Widget getLayout() {
    return _postsList == null
        ? Center(child: CupertinoActivityIndicator())
        : Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
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
                    child: ListView.builder(
                        itemCount: _postsList.length,
                        itemBuilder: (ctx, index) {
                          return Card(
                            elevation: 1.0,
                            shape: Border.all(width: 1.0, color: Colors.black),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CachedNetworkImage(
                                  placeholder: (ctx,str) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Center(child: CupertinoActivityIndicator(),),
                                    );
                                  },
                                    imageUrl: _postsList[index].image,
                                    fit: BoxFit.contain,
                                  ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      FlatButton.icon(
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onPressed: () => like(index,
                                              SplashScreen.myProfile.uid),
                                          icon: Icon(
                                            _postsList[index].likes.containsKey(
                                                    SplashScreen.myProfile.uid)
                                                ? CustomIcons.thumbs_up_filled
                                                : CustomIcons.thumbs_up,
                                            color: _postsList[index]
                                                    .likes
                                                    .containsKey(SplashScreen
                                                        .myProfile.uid)
                                                ? Theme.of(context).primaryColor
                                                : Colors.black,
                                          ),
                                          label: Text(_postsList[index]
                                              .likes
                                              .length
                                              .toString())),
                                      FlatButton.icon(
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onPressed: () => dislike(index,
                                              SplashScreen.myProfile.uid),
                                          icon: Icon(
                                            _postsList[index]
                                                    .dislikes
                                                    .containsKey(SplashScreen
                                                        .myProfile.uid)
                                                ? CustomIcons.thumbs_down_filled
                                                : CustomIcons.thumbs_down,
                                            color: _postsList[index]
                                                    .dislikes
                                                    .containsKey(SplashScreen
                                                        .myProfile.uid)
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                          label: Text(_postsList[index]
                                              .dislikes
                                              .length
                                              .toString())),
                                      FlatButton.icon(
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onPressed: () => comment(index,SplashScreen.myProfile.uid),
                                          icon: Icon(CustomIcons.comment),
                                          label: Text(
                                              _postsList[index].comments == null
                                                  ? '0'
                                                  : _postsList[index]
                                                      .comments
                                                      .length
                                                      .toString())),
                                      FlatButton.icon(
                                          onPressed: () {},
                                          icon: Icon(CustomIcons.share_bold),
                                          label: Text('0')),
                                    ],
                                  ),
                                ),
                                _postsList[index].caption.toString() ==
                                            'null' ||
                                        _postsList[index]
                                            .caption
                                            .toString()
                                            .isEmpty
                                    ? SizedBox()
                                    : Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          _postsList[index].caption,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                _postsList[index].location.toString() ==
                                            'null' ||
                                        _postsList[index]
                                            .location
                                            .toString()
                                            .isEmpty
                                    ? SizedBox()
                                    : Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          _postsList[index].location,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                              ],
                            ),
                          );
                        }),
                  ),
                )
              ],
            ),
          );
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
    }).catchError((error) {
      showAlertError(error.toString(), context);
    });
    SplashScreen.postRef
        .document(widget.uid)
        .collection('userPosts')
        .getDocuments()
        .then((doc) {
      List<Post> posts = [];
      doc.documents.forEach((f) {
        LinkedHashMap<dynamic, dynamic> comments = f.data['comments'];
        posts.add(Post(
            f.data['id'],
            f.data['caption'],
            f.data['image'],
            f.data['location'],
            f.data['owner'],
            f.data['likes'],
            f.data['dislikes'],
            int.parse(f.data['timestamp'].toString()),
            comments.length == 0 ? null : f.data['comments']));
      });
      setState(() {
        _postsList = posts;
      });
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/models/data.dart';
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
        : Column(
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
                                fit: BoxFit.fill,
                                imageUrl: _postsList[index].image,
                                placeholder: (ctx, string) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child: CupertinoActivityIndicator()),
                                  );
                                },
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(CustomIcons.icons8_thumbs_up_100),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(_postsList[index].likes.toString()),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(CustomIcons.icons8_thumbs_down_100),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(_postsList[index].dislikes.toString()),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(CustomIcons.icons8_chat_message_100),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(_postsList[index].comments.length.toString()),
                                        )
                                      ],
                                    ),
                                    Icon(CustomIcons.share_bold),
                                  ],
                                ),
                              ),
                              _postsList[index].caption.toString() == 'null' ||
                                      _postsList[index]
                                          .caption
                                          .toString()
                                          .isEmpty
                                  ? SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        _postsList[index].caption,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                              _postsList[index].location.toString() == 'null' ||
                                      _postsList[index]
                                          .location
                                          .toString()
                                          .isEmpty
                                  ? SizedBox()
                                  : Container(
                                      padding: const EdgeInsets.all(20),
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
      showAlertError(error.message, context);
    });
    SplashScreen.postRef
        .document(widget.uid)
        .collection('userPosts')
        .getDocuments()
        .then((doc) {
      List<Post> posts = [];
      doc.documents.forEach((f) {
        posts.add(Post(
            f.data['id'],
            f.data['caption'],
            f.data['image'],
            f.data['location'],
            f.data['owner'],
            f.data['likes'],
            f.data['dislikes'],
            int.parse(f.data['timestamp'].toString()),
            {}));
      });
      setState(() {
        _postsList = posts;
      });
    }).catchError((error) {
      showAlertError(error.message, context);
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

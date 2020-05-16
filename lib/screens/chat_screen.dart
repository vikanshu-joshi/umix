import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/screens/MyProfile/my_friends.dart';
import 'package:umix/screens/chat.dart';
import 'package:umix/screens/splash_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _search;
  CollectionReference chats = Firestore.instance.collection('chats');

  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget getChat(String key, LinkedHashMap<String, dynamic> map) {
    if (map[key]['name'] == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
            return Chat(map[key]['name'], map[key]['image'], map[key]['id']);
          }));
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(5),
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.black,
            radius: 30,
            child: CircleAvatar(
              radius: 27,
              backgroundImage: map[key]['image'] == 'default'
                  ? AssetImage('assets/images/default.png')
                  : NetworkImage(map[key]['image']),
            ),
          ),
          title: Text(map[key]['name'].toString()),
          subtitle: Text(map[key]['message'].toString()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            elevation: 5,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      LineIcons.search,
                      color: Colors.black,
                    ),
                    onPressed: null),
                Expanded(
                    child: TextField(
                  controller: _search,
                  maxLines: 1,
                  onSubmitted: (String name) {},
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Search..."),
                )),
                IconButton(
                    icon: Icon(
                      CustomIcons.send_message_phone,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (ctx) {
                            return MyFriends();
                          }));
                    })
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
                stream: chats.document(SplashScreen.myProfile.uid).snapshots(),
                builder: (ctx, snapshots) {
                  if (!snapshots.hasData) {
                    return Center(
                      child: Text('Loading.........'),
                    );
                  }
                  LinkedHashMap<String, dynamic> data = snapshots.data.data;
                  List<String> keys = data.keys.toList();
                  return ListView.builder(
                      itemCount: keys.length,
                      itemBuilder: (ctx, index) {
                        return getChat(keys[index], data);
                      });
                }),
          ))
        ],
      )),
    );
  }
}

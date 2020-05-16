import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:umix/custom/custom_icons_icons.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Chat extends StatefulWidget {
  final String name;
  final String image;
  final String id;
  Chat(this.name, this.image, this.id);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _message;
  CollectionReference chats;
  DateFormat formatDate = DateFormat.yMd();
  DateFormat formatTime = DateFormat.Hm();

  @override
  void initState() {
    chats = Firestore.instance.collection('chats');
    _message = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void sendMessage(String type) async {
    String message = _message.text.trim();
    _message.text = '';
    if (message.isEmpty) {
      return;
    }
    var id = Uuid().v4().toString();
    var time = DateTime.now().millisecondsSinceEpoch;
    var t = FieldValue.serverTimestamp();
    await chats
        .document(widget.id)
        .collection(SplashScreen.myProfile.uid)
        .document(id)
        .setData({
      'id': id,
      'message': message,
      'type': type,
      'timestamp': t,
      'time': time,
      'owner': 'me'
    });
    await chats
        .document(SplashScreen.myProfile.uid)
        .collection(widget.id)
        .document(id)
        .setData({
      'id': id,
      'message': message,
      'type': type,
      'timestamp': t,
      'time': time,
      'owner': 'user',
    });
    chats.document(widget.id).updateData({
      SplashScreen.myProfile.uid: {
        'latest': t,
        'message': message,
        'id': SplashScreen.myProfile.uid,
        'image': SplashScreen.myProfile.image,
        'name': SplashScreen.myProfile.name
      }
    });
    chats.document(SplashScreen.myProfile.uid).updateData({
      widget.id: {
        'latest': t,
        'message': 'You : ' + message,
        'id': widget.id,
        'image': widget.image,
        'name': widget.name
      }
    });
  }

  Widget getMessageLayout(LinkedHashMap data) {
    if (data['owner'] != 'me') {
      String time = formatDate.format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(data['time'].toString()))) +
          '\n' +
          formatTime.format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(data['time'].toString())));
      return Slidable(
        secondaryActions: <Widget>[
          SlideAction(
              child: Text(
            time,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          )),
        ],
        actionPane: SlidableScrollActionPane(),
        child: Container(
          padding: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width,
          child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                data['message'],
                style: TextStyle(fontSize: 17),
              )),
          alignment: Alignment.centerRight,
        ),
      );
    }
    String time = formatDate.format(data['timestamp'].toDate()) +
        '\n' +
        formatTime.format(data['timestamp'].toDate());
    return Slidable(
      actions: <Widget>[
        SlideAction(
            child: Text(
          time,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        )),
      ],
      actionPane: SlidableScrollActionPane(),
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: Text(
              data['message'],
              style: TextStyle(fontSize: 17, color: Colors.white),
            )),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget bottomNewMessage() {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Device.get().isAndroid
                  ? TextFormField(
                      controller: _message,
                      maxLines: 1,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          hintText: 'Enter message', border: InputBorder.none),
                    )
                  : CupertinoTextField(
                      controller: _message,
                      placeholder: 'Enter message',
                    )),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: IconButton(
                icon: Icon(
                  CustomIcons.send,
                  color: Colors.black,
                ),
                onPressed: () => sendMessage('text')),
          )
        ],
      ),
    );
  }

  Widget getLayout() {
    return Column(
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
              stream: chats
                  .document(SplashScreen.myProfile.uid)
                  .collection(widget.id)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, snapshots) {
                if (!snapshots.hasData) {
                  return Center(child: Text('Loading.......'));
                }
                int count = snapshots.data.documents.length;
                if (count == 0) {
                  return Center(
                    child: Text('No Messages'),
                  );
                }
                return ListView.builder(
                    reverse: true,
                    itemCount: count,
                    itemBuilder: (ctx, index) {
                      return getMessageLayout(
                          snapshots.data.documents[index].data);
                    });
              }),
        )),
        bottomNewMessage()
      ],
    );
  }

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () => Navigator.of(context).pop()),
            middle: Text(
              widget.name,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop()),
            title: Text(
              widget.name,
              overflow: TextOverflow.ellipsis,
            ),
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

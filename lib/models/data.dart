import 'dart:collection';

import 'package:intl/intl.dart';

class User {
  String name = 'Batman';
  String email = 'bruce.wayne@wayne.enterprises.com';
  String dob = DateFormat.yMMMMd().format(DateTime.now());
  String gender = 'Other';
  String image = 'default';
  String uid = '';
  User(this.name, this.email, this.dob, this.gender, this.image, this.uid);
}

class Post {
  String id;
  String caption;
  String image;
  String location;
  String owner;
  LinkedHashMap<dynamic,dynamic> likes;
  LinkedHashMap<dynamic,dynamic> dislikes;
  LinkedHashMap<dynamic, dynamic> comments;
  int timestamp;
  Post(this.id, this.caption, this.image, this.location, this.owner, this.likes,this.dislikes,this.timestamp, this.comments);
}

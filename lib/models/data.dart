import 'package:intl/intl.dart';

class User {
  String name = 'Batman';
  String email = 'bruce.wayne@wayne.enterprises.com';
  String dob = DateFormat.yMMMMd().format(DateTime.now());
  String gender = 'Other';
  String image = 'default';
  String uid = '';
  User(this.name,this.email,this.dob,this.gender,this.image,this.uid);
}

class Post{
  String caption;
  bool multiImages;
  List<String> images;
  int likes;
  
}
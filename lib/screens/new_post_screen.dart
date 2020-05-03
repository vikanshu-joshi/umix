import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:line_icons/line_icons.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  PageController _page = PageController(
    initialPage: 1,
  );
  List<String> imagesList;

  @override
  void initState() {
    loadImageList();
    super.initState();
  }

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: Text('Create New Post'),
            trailing: FlatButton(onPressed: () {}, child: Text('Next')),
          )
        : AppBar(
            title: Text('Create New Post'),
            actions: <Widget>[
              FlatButton(onPressed: () {}, child: Text('Next')),
            ],
          );
  }

  void loadImageList() async {
    LinkedHashMap obj = await FlutterGallaryPlugin.getAllImages;
    List<dynamic> list = obj['URIList'];
    var strings = list.cast<String>().toList();
    setState(() {
      imagesList = strings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: PageView(
        controller: _page,
        children: <Widget>[
          GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5),
            itemBuilder: (ctx, index) {
              return Container(
                  color: Theme.of(context).accentColor,
                  child: ProgressiveImage(
                      placeholder: AssetImage('assets/images/loading.png'),
                      thumbnail: FileImage(File(imagesList[index])),
                      image: FileImage(File(imagesList[index])),
                      width: MediaQuery.of(context).size.width * 0.499,
                      height: MediaQuery.of(context).size.width * 0.499));
            },
            itemCount: imagesList == null ? 0 : imagesList.length,
          ),
          Center(child: Text('Camera')),
          Center(child: Text('Videos')),
        ],
      ),
      bottomNavigationBar: TitledBottomNavigationBar(
          activeColor: Colors.red,
          onTap: (index) {
            _page.animateToPage(index,
                duration: Duration(milliseconds: 800), curve: Curves.ease);
          },
          items: [
            TitledNavigationBarItem(
                title: Text('Gallery'),
                icon: Device.get().isIos
                    ? CupertinoIcons.folder_open
                    : LineIcons.image),
            TitledNavigationBarItem(
                title: Text('Camera'),
                icon: Device.get().isIos
                    ? CupertinoIcons.photo_camera
                    : LineIcons.camera),
            TitledNavigationBarItem(
                title: Text('Videos'),
                icon: Device.get().isIos
                    ? CupertinoIcons.video_camera
                    : LineIcons.video_camera),
          ]),
    );
  }
}

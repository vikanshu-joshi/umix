import 'dart:collection';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:umix/screens/final_post_upload.dart';
import 'package:umix/widgets/common_widgets.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  PageController _page = PageController(
    initialPage: 1,
  );
  List<String> imagesList;
  int currentIndex = 1;
  bool imageCaptured = false;
  File loadedImage;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _captureImage(ImageSource source) async {
    var result = await ImagePicker.pickImage(source: source,imageQuality: 50);
    if (result != null) {
      setState(() {
        imageCaptured = true;
        loadedImage = result;
      });
    }
  }

  Widget getCameraPage() {
    if (!imageCaptured) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              _captureImage(ImageSource.camera);
            },
            child: Text('Open Camera'),
            color: Theme.of(context).accentColor,
          ),
          RaisedButton(
            onPressed: () {
              _captureImage(ImageSource.gallery);
            },
            child: Text('Open Gallery'),
            color: Theme.of(context).accentColor,
          )
        ],
      );
    }
    return Column(
      children: <Widget>[
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(2),
          width: MediaQuery.of(context).size.width,
          child: ProgressiveImage(
              fit: BoxFit.contain,
              placeholder: AssetImage('assets/images/loading.png'),
              thumbnail: AssetImage('assets/images/loading.png'),
              image: FileImage(loadedImage),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height),
          color: Colors.red.withOpacity(0.5),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _captureImage(ImageSource.camera);
                    },
                    child: Text('Open Camera'),
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          loadedImage = null;
                          imageCaptured = false;
                        });
                      }),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _captureImage(ImageSource.gallery);
                    },
                    child: Text('Open Gallery'),
                    color: Theme.of(context).accentColor,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    loadImageList();
    super.initState();
  }

  Widget getAppBar() {
    return Device.get().isIos
        ? CupertinoNavigationBar(
            leading: Text('Create New Post'),
            trailing: FlatButton(
                onPressed: () {
                  nextFinalPostScreen(context);
                },
                child: Text('Next')),
          )
        : AppBar(
            title: Text('Create New Post'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    nextFinalPostScreen(context);
                  },
                  child: Text('Next')),
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

  void nextFinalPostScreen(BuildContext context) async {
    bool result = await Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: false,
        builder: (ctx) {
          return FinalPostUpload(imageCaptured ? loadedImage : null);
        }));
    if(result){
      setState(() {
        imageCaptured = false;
        loadedImage = null;
      });
    }else{
      showAlertError('Failed', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          currentIndex = index;
        },
        controller: _page,
        children: <Widget>[
          GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5),
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () {
                  loadedImage = File(imagesList[index]);
                  setState(() {
                    imageCaptured = true;
                    _page.animateToPage(1,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.ease);
                  });
                },
                child: Container(
                    color: Theme.of(context).accentColor,
                    child: ProgressiveImage(
                        placeholder: AssetImage('assets/images/loading.png'),
                        thumbnail: FileImage(File(imagesList[index])),
                        image: FileImage(File(imagesList[index])),
                        width: MediaQuery.of(context).size.width * 0.495,
                        height: MediaQuery.of(context).size.width * 0.495)),
              );
            },
            itemCount: imagesList == null ? 0 : imagesList.length,
          ),
          getCameraPage(),
        ],
      ),
      bottomNavigationBar: TitledBottomNavigationBar(
          currentIndex: currentIndex,
          enableShadow: true,
          activeColor: Colors.red,
          onTap: (index) {
            currentIndex = index;
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
          ]),
    );
  }
}

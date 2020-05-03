import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:progressive_image/progressive_image.dart';

class FinalPostUpload extends StatefulWidget {
  final File image;
  FinalPostUpload(this.image);
  @override
  _FinalPostUploadState createState() => _FinalPostUploadState();
}

Widget getAppBar() {
  return Device.get().isIos
      ? CupertinoNavigationBar(
          middle: Text('Enter final details'),
          trailing: Icon(
            CupertinoIcons.forward,
            color: Colors.black,
          ),
        )
      : AppBar(
          title: Text('Enter final details'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.check, color: Colors.black), onPressed: null)
          ],
        );
}

class _FinalPostUploadState extends State<FinalPostUpload> {
  TextEditingController _caption;

  @override
  void initState() {
    _caption = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            widget.image == null
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.all(2),
                    color: Colors.red,
                    child: Container(
                      width: mediaQuery.size.width,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(widget.image),
                              fit: BoxFit.fill)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: ProgressiveImage(
                            fit: BoxFit.contain,
                            placeholder:
                                AssetImage('assets/images/loading.png'),
                            thumbnail: AssetImage('assets/images/loading.png'),
                            image: FileImage(widget.image),
                            width: mediaQuery.size.width,
                            height: mediaQuery.size.height * 0.5),
                      ),
                    ),
                  ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Device.get().isIos
                        ? CupertinoTextField(
                            controller: _caption,
                            placeholder: 'Enter Caption',
                          )
                        : TextField(
                            controller: _caption,
                            decoration:
                                InputDecoration(hintText: 'Enter Caption'),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Device.get().isIos
                        ? CupertinoTextField(
                            controller: _caption,
                            placeholder: 'Enter Location',
                          )
                        : TextField(
                            controller: _caption,
                            decoration:
                                InputDecoration(hintText: 'Enter Location'),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: RaisedButton(
                      padding: const EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.my_location),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Use Current Location'),
                            )
                          ],
                        ),
                        onPressed: () {}),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

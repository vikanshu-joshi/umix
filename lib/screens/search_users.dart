import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:line_icons/line_icons.dart';
import 'package:umix/models/data.dart';
import 'package:umix/screens/splash_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:umix/widgets/common_widgets.dart';

class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  List<User> _searchedUsers;
  TextEditingController _search;
  ProgressDialog _progressDialog;
  String _searchParam = 'name';

  void handleSearch(String name) async {
    _progressDialog.show();
    SplashScreen.userRef
        .where(
          _searchParam,
          isGreaterThanOrEqualTo: name.trim(),
        )
        .getDocuments()
        .then((users) {
      List<User> user = [];
      users.documents.forEach((f) {
        User value = User(f.data['name'], f.data['email'], f.data['dob'],
            f.data['gender'], f.data['image'], f.data['uid']);
        if (f.data['uid'] != SplashScreen.mUser.uid) {
          user.add(value);
        }
      });
      if (user.isEmpty) {
        _progressDialog.hide();
        setState(() {
          _searchedUsers = null;
        });
        showAlertError('No users found', context);
      } else {
        _progressDialog.hide();
        setState(() {
          _searchedUsers = user;
        });
      }
    }).catchError((error) {
      _progressDialog.hide();
      showAlertError(error.toString(), context);
    });
  }

  void _changeSearchParam() async {
    String chosen;
    if (Device.get().isIos) {
      chosen = await showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return CupertinoActionSheet(
              title: Text('Choose an Option'),
              message:
                  Text('The app will search based on one of the parameters'),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('name'),
                  child: Text('Search by Name'),
                  isDefaultAction: true,
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop('email'),
                  child: Text('Search by Email'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(_searchParam),
                child: Text('Cancel'),
              ),
            );
          });
      _searchParam = chosen;
    } else {
      chosen = await showModalBottomSheet(
          isDismissible: false,
          context: context,
          builder: (_) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  Container(
                    child: ListTile(
                      leading: SizedBox(),
                      title: FlatButton(
                          onPressed: () => Navigator.of(context).pop('name'),
                          child: Text(
                            'Search by Name',
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          )),
                      trailing: _searchParam == 'name'
                          ? Icon(
                              Icons.done,
                              color: Colors.green,
                            )
                          : SizedBox(),
                    ),
                  ),
                  Divider(),
                  Container(
                    child: ListTile(
                      leading: SizedBox(),
                      title: FlatButton(
                          onPressed: () => Navigator.of(context).pop('email'),
                          child: Text(
                            'Search by Email',
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          )),
                      trailing: _searchParam == 'email'
                          ? Icon(
                              Icons.done,
                              color: Colors.green,
                            )
                          : SizedBox(),
                    ),
                  ),
                  Divider(),
                  Container(
                    child: FlatButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_searchParam),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        )),
                  ),
                ],
              ),
            );
          });
      _searchParam = chosen;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    _progressDialog = ProgressDialog(context,
        isDismissible: true, type: ProgressDialogType.Normal);
    _progressDialog.style(
      progressWidget: Container(
        padding: const EdgeInsets.all(15.0),
        child: CircularProgressIndicator(),
      ),
      elevation: 2,
      message: 'Please Wait.....',
      borderRadius: 5,
    );
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 100),
            color: Colors.white,
            child: _searchedUsers == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          LineIcons.search,
                          size: mediaQuery.size.width * 0.2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Search for Users',
                            style: TextStyle(
                                fontSize: mediaQuery.size.width * 0.05),
                          ),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchedUsers.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(_searchedUsers[index].name),
                              contentPadding: EdgeInsets.all(10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(_searchedUsers[index].image),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    }),
          ),
          Positioned(
            top: 15,
            right: 15,
            left: 15,
            child: Card(
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
                    onSubmitted: handleSearch,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: "Search..."),
                  )),
                  IconButton(
                      icon: Icon(LineIcons.list), onPressed: _changeSearchParam)
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

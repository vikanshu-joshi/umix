import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

void showAlertError(String error,BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Device.get().isIos
              ? CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(error),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text('Error'),
                  content: Text(error),
                  elevation: 5.0,
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'))
                  ],
                );
        });
  }


import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

/// [Show error msg]
void showErrorMsg(String msg) {
  showSimpleNotification(
    Text(
      msg,
      style: TextStyle(color: Colors.white),
    ),
    leading: Icon(
      Icons.error,
      color: Colors.white,
    ),
    duration: Duration(seconds: 3),
    position: NotificationPosition.bottom,
    background: Colors.red,
  );
}

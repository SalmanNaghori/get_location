import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  //show toast
  static void appToast(String message,
      {Color toastColor = Colors.white, Color textColor = Colors.black}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: toastColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}

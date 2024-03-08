import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:get_location/core/util/logger.dart';

class AppUtils {
  AppUtils._();

  static final instance = AppUtils._();

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

  //Todo: Get FCM token
  Timer? timer;
  getFcmToken() async {
    if (SharedPrefUtils.getFcmToken() == "") {
      timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) {
        getFcm();
      });
    } else {
      getFcm();
    }
  }

  getFcm() {
    FirebaseMessaging.instance.getToken().then((token) async {
      await SharedPrefUtils.setFcmToken(token!);
      timer?.cancel();
      logger.w("Firebase token ~~~~~~~> $token");
      if (kDebugMode) {
        print("Firebase token ~~~~~~~> $token");
      }
    });

    // StartupService.saveAppVersion();
    // StartupService.saveDeviceModel();
    // if (Platform.isIOS) {
    //   AppUtils().getDeviceToken();
    // }
  }
}

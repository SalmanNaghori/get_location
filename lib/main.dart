import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_location/core/constant/color_const.dart';
import 'package:get_location/core/storage/shared_pref.dart';
import 'package:get_location/feature/get_location.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  orientations();
  configLoading();

  await Firebase.initializeApp();
  SharedPrefUtils.init();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.transparent
    ..indicatorColor = ConstColor.primaryColor
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..indicatorSize = 60
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false
    ..maskColor = Colors.black54
    ..textColor = Colors.transparent
    ..boxShadow = <BoxShadow>[]
    ..userInteractions = false;
}

void orientations() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

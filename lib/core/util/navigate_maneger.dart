import 'package:flutter/cupertino.dart';

import 'package:get_location/core/navigator/navigator.dart';

Future<dynamic> navigateToPage(Widget routePage, {Widget? currentWidget}) {
  try {
    FocusManager.instance.primaryFocus!.unfocus();
  } catch (e, s) {
    //  FirebaseCrashlytics.instance.recordError(e, s);
  }
  return Navigator.push(
    GlobalVariable.appContext,
    CupertinoPageRoute(builder: (context) => routePage),
  );
}

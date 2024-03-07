import 'package:flutter/widgets.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Implement your app lifecycle state changes here
    if (state == AppLifecycleState.resumed) {
      // Resume location updates or perform other actions
    } else if (state == AppLifecycleState.paused) {
      // Pause or stop location updates
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_location/core/util/logger.dart';

class NotificationsService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  init() {
    //Todo:forground
    FirebaseMessaging.onMessage.listen(
      (message) {
        logger.f("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          logger.d(message.notification!.title);
          logger.d(message.notification!.body);
          logger.d("message.data11 ${message.data}");
          initialize();
          createAndDisplayNotification(message);
        }
      },
    );

    //Todo:background notification
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        logger.f("====>>>>FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          initialize();
          logger.d(message.notification!.title);
          logger.d(message.notification!.body);
          logger.d("message.data22 ${message.data['_id']}");
        }
      },
    );

    //Todo:App kill
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        Future.delayed(
          const Duration(seconds: 2),
          () async {
            await Firebase.initializeApp();
            if (message != null) {
              if (message.data['_id'] != null) {
                navigateToOtherScreen(message.data['_id']);
              }
            }
          },
        );
      },
    );
  }

  void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        logger.d("======>>>>message11111> ${response.payload.toString()}");
        logger.d("onSelectNotification");
        if (response.payload!.isNotEmpty) {
          String id = response.payload.toString();
          logger.d("======>>>>Router Value1234 $id");

          // Navigate to your screen using the retrieved id
          logger.d("push");

          if (id.isNotEmpty) {
            logger.d("push");

            navigateToOtherScreen(id);
          }
        }
      },
    );
  }

  Future<void> navigateToOtherScreen(String id) async {
    // Future.delayed(
    //   const Duration(milliseconds: 300),
    //   () async {
    //     await navigateToPage(
    //       NavigateScreen(title: id),
    //     );
    //   },
    // );
  }

  // after initialize we create channel in createanddisplaynotification method
  static Future<void> createAndDisplayNotification(
      RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (message.notification == null) {
        // Handle the case where the notification is null
        throw Exception("Notification is null in the received message");
      }

      NotificationDetails notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          "get_location_status",
          "Get Notifications",
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: "@mipmap/ic_launcher",
        ),
      );

      try {
        // Your existing code...
        await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title ?? "Default Title",
          message.notification!.body ?? "Default Body",
          notificationDetails,
        );
      } catch (e, stackTrace) {
        logger.e("Error during notification show: $e\n$stackTrace");
        // Handle the error as needed
      }
    } catch (e, stackTrace) {
      // Log the error and stack trace for debugging
      logger.e("Error during notification creation: $e\n$stackTrace");

      // Handle the error based on your requirements
      // You can also rethrow the exception if you want to propagate it further
      // throw e;
    }
  }

  void requestNotificationsPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.d("=====>>>>>>>User Granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      logger.w("====>>>>>User Granted provisional permission");
    } else {
      logger.e(">>>>>>=======>>>>User denied permission");
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }
}

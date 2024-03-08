import 'dart:convert';

import 'package:get_location/core/storage/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:get_location/core/util/logger.dart';

class ApiHelper {
  Future<void> sendNotification(String title) async {
    try {
      final notificationData = {
        "to": SharedPrefUtils.getFcmAdminToken(),
        "notification": {
          "body":
              "${SharedPrefUtils.getUserModel().firstName} ${SharedPrefUtils.getUserModel().secondName}",
          "title": title,
          "android_channel_id": "get_location_status",
          "sound": true
        },
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Authorization':
              'key=AAAAmf5Lhlo:APA91bHPtN5402eUiausLkwVCNSv8ZJSKaDoDBA-W4HqyLx8mbPVYbGW6hKgvKRtqdEqCwqW_009T56Nzh2dzx8kEGDOs1DZDlkTvqNF0pk4FD5D-R_8F6Y1PMUUJqktXEsi4GUeO3ZG',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notificationData),
      );

      // Handle the response
      if (response.statusCode == 200) {
        logger.d('Notification sent successfully');
      } else {
        logger.e(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error sending notification: $error');
    }
  }
}

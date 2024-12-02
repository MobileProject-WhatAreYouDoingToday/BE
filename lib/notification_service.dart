import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('your_channel_name');

  static Future<void> showNotification(String title, String message) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Failed to show notification: '${e.message}'.");
    }
  }
}
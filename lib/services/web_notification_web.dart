// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

Future<bool> requestWebNotificationPermission() async {
  try {
    if (html.Notification.permission != 'granted') {
      final result = await html.Notification.requestPermission();
      debugPrint('Web notification permission requested: $result');
      return result == 'granted';
    }
    return true;
  } catch (e) {
    debugPrint('Error requesting web notification permission: $e');
    return false;
  }
}

void showWebNotification(String title, String body) {
  try {
    if (html.Notification.permission == 'granted') {
      html.Notification(
        title,
        body: body,
        icon: 'icons/Icon-192.png',
      );
    }
  } catch (e) {
    debugPrint('Error showing web notification: $e');
  }
}

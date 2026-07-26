import 'package:flutter/foundation.dart';

Future<bool> requestWebNotificationPermission() async {
  debugPrint('Web notifications not available on non-web platforms.');
  return false;
}

void showWebNotification(String title, String body) {}

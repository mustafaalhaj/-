import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'web_notification_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // ✅ iOS: طلب الصلاحيات صراحةً لضمان عمل الإشعارات عند إغلاق التطبيق
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // طلب الصلاحيات على iOS بشكل صريح فور التهيئة
    if (!kIsWeb) {
      await requestPermissions();
    }

    // إنشاء القنوات على Android
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel_v3',
          'Prayer Times with Adhan',
          description: 'Notifications for prayer times with full Adhan sound',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'adhkar_reminders_channel',
          'أذكار وتنبيهات إيمانية',
          description: 'تنبيهات أذكار الصباح والمساء والكهف وقيام الليل',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }
  }

  Future<void> requestPermissions() async {
    // ✅ 1. Web: طلب إذن إشعارات متصفح الويب (Browser Notifications Prompt)
    if (kIsWeb) {
      try {
        await requestWebNotificationPermission();
      } catch (e) {
        debugPrint('Web notification permission error: $e');
      }
      return;
    }

    // ✅ 2. iOS: طلب صلاحيات الإشعارات الكاملة
    final iosImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // ✅ 3. Android: طلب إذن الإشعارات للموبايل
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> schedulePrayerNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      if (kIsWeb) {
        final now = DateTime.now();
        final diff = scheduledTime.difference(now);
        if (!diff.isNegative) {
          Future.delayed(diff, () {
            showWebNotification(title, body);
          });
        }
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel_v3',
            'Prayer Times with Adhan',
            channelDescription: 'Notifications for prayer times with full Adhan sound',
            importance: Importance.max,
            priority: Priority.max,
            sound: RawResourceAndroidNotificationSound('adhan'),
            audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'adhan.caf',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

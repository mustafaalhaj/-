import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../providers/notification_preferences_provider.dart';

/// محرك جدولة التنبيهات والأذكار المحلية
class LocalReminderScheduler {
  static final LocalReminderScheduler _instance =
      LocalReminderScheduler._internal();
  factory LocalReminderScheduler() => _instance;
  LocalReminderScheduler._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _adhkarChannelId = 'adhkar_reminders_channel';
  static const String _adhkarChannelName = 'أذكار وتنبيهات إيمانية';
  static const String _adhkarChannelDesc =
      'تنبيهات أذكار الصباح والمساء والكهف وقيام الليل';

  // معرفات الإشعارات الفريدة لمنع التكرار
  static const int _idMorningAdhkar = 5001;
  static const int _idEveningAdhkar = 5002;
  static const int _idFridayKahf = 5003;
  static const int _idQiyamLayl = 5004;

  /// تهيئة قنوات الإشعارات المحلية
  Future<void> initChannels() async {
    tz.initializeTimeZones();

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          _adhkarChannelId,
          _adhkarChannelName,
          description: _adhkarChannelDesc,
          importance: Importance.high,
          playSound: true,
        ),
      );
    }
  }

  /// إعادة جدولة كافة التنبيهات بناءً على تفضيلات المستخدم
  Future<void> syncAllReminders(
    NotificationPreferencesProvider prefsProvider,
  ) async {
    await initChannels();

    // 1. أذكار الصباح
    if (prefsProvider.morningAdhkar) {
      await scheduleDailyReminder(
        id: _idMorningAdhkar,
        title: 'أذكار الصباح ☀️',
        body: 'أصبحنا وأصبح الملك لله.. حان وقت أذكار الصباح لتبدأ يومك ببركة.',
        time: prefsProvider.morningTime,
      );
    } else {
      await _notificationsPlugin.cancel(_idMorningAdhkar);
    }

    // 2. أذكار المساء
    if (prefsProvider.eveningAdhkar) {
      await scheduleDailyReminder(
        id: _idEveningAdhkar,
        title: 'أذكار المساء 🌙',
        body: 'أمسى وأمسى الملك لله.. حان وقت أذكار المساء لتحصين نفسك.',
        time: prefsProvider.eveningTime,
      );
    } else {
      await _notificationsPlugin.cancel(_idEveningAdhkar);
    }

    // 3. سورة الكهف يوم الجمعة
    if (prefsProvider.fridayKahf) {
      await scheduleFridayKahfReminder();
    } else {
      await _notificationsPlugin.cancel(_idFridayKahf);
    }

    // 4. قيام الليل
    if (prefsProvider.qiyamLayl) {
      await scheduleDailyReminder(
        id: _idQiyamLayl,
        title: 'صلاة قيام الليل 🌌',
        body: 'شرف المؤمن قيام الليل.. ساعة استجابة ونزول إلهي مبارك.',
        time: const TimeOfDay(hour: 2, minute: 30),
      );
    } else {
      await _notificationsPlugin.cancel(_idQiyamLayl);
    }
  }

  /// جدولة تذكير يومي في وقت محدد
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // إذا كان الوقت قد مضى اليوم، نجدوله للغد
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _adhkarChannelId,
            _adhkarChannelName,
            channelDescription: _adhkarChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // يتكرر يومياً
      );
      debugPrint('Scheduled daily reminder [$id] at $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling daily reminder [$id]: $e');
    }
  }

  /// جدولة تذكير سورة الكهف يوم الجمعة
  Future<void> scheduleFridayKahfReminder() async {
    try {
      final now = DateTime.now();
      int daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
      if (daysUntilFriday == 0 && now.hour >= 9) {
        daysUntilFriday = 7; // الجمعة القادمة
      }

      final fridayDate = DateTime(
        now.year,
        now.month,
        now.day + daysUntilFriday,
        9, // 09:00 صباحاً
        0,
      );

      await _notificationsPlugin.zonedSchedule(
        _idFridayKahf,
        'نور ما بين الجمعتين 📖',
        'خير أيام الأسبوع يوم الجمعة.. لا تنسَ قراءة سورة الكهف والصلاة على النبي ﷺ.',
        tz.TZDateTime.from(fridayDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _adhkarChannelId,
            _adhkarChannelName,
            channelDescription: _adhkarChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // يتكرر أسبوعياً
      );
      debugPrint('Scheduled Friday Al-Kahf reminder at $fridayDate');
    } catch (e) {
      debugPrint('Error scheduling Friday Kahf reminder: $e');
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import '../data/hijri_repository.dart';
import '../data/events_loader.dart';
import '../domain/models/hijri_date.dart';

/// Service for managing Hijri calendar notifications
class HijriNotificationService {
  static final HijriNotificationService _instance =
      HijriNotificationService._internal();
  factory HijriNotificationService() => _instance;
  HijriNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final HijriRepository _repository = HijriRepository();
  final EventsLoader _eventsLoader = EventsLoader();

  static const String _channelId = 'hijri_calendar_channel';
  static const String _channelName = 'Elektronic Hijri Calendar';
  static const String _channelDescription =
      'Notifications for Islamic events and fasting days';

  /// Initialize the notification service
  Future<void> initialize() async {
    await _repository.initialize();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    tz.initializeTimeZones();
    await _notifications.initialize(initSettings);

    // Register background task
    await Workmanager().initialize(_callbackDispatcher);
    await _scheduleBackgroundTask();
  }

  /// Schedule background task to check for reminders
  Future<void> _scheduleBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      'hijri_reminder_check',
      'hijriReminderCheck',
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected, // Changed to connected to be safe
      ),
    );
  }

  /// Schedule all reminders
  Future<void> scheduleAllReminders() async {
    await _cancelAllReminders();

    // Schedule Monday/Thursday fasting reminders
    await _scheduleFastingReminders();

    // Schedule white days reminders
    await _scheduleWhiteDaysReminders();

    // Schedule event reminders
    await _scheduleEventReminders();

    // Schedule Ramadan reminders if applicable
    if (_repository.isRamadan()) {
      await _scheduleRamadanReminders();
    }
  }

  /// Schedule Monday and Thursday fasting reminders
  Future<void> _scheduleFastingReminders() async {
    final today = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      final weekday = date.weekday;

      // Monday = 1, Thursday = 4
      if (weekday == 1 || weekday == 4) {
        final scheduledDate = DateTime(
          date.year,
          date.month,
          date.day,
          20, // 8 PM the day before
          0,
        ).subtract(const Duration(days: 1));

        if (scheduledDate.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: 1000 + i,
            title: 'تذكير بالصيام 🌙',
            body:
                'غدًا يوم ${weekday == 1 ? "الاثنين" : "الخميس"} – يُستحب الصيام',
            scheduledDate: scheduledDate,
          );
        }
      }
    }
  }

  /// Schedule white days (13, 14, 15) reminders
  Future<void> _scheduleWhiteDaysReminders() async {
    final today = HijriDate.now();

    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      int targetMonth = today.hMonth + monthOffset;
      int targetYear = today.hYear;

      if (targetMonth > 12) {
        targetMonth -= 12;
        targetYear++;
      }

      // Reminder for day 13
      final day13 = HijriDate.fromHijri(targetYear, targetMonth, 13);
      final gregorian13 = day13.toGregorian();

      final reminderDate13 = DateTime(
        gregorian13.year,
        gregorian13.month,
        gregorian13.day,
        20,
        0,
      ).subtract(const Duration(days: 1));

      if (reminderDate13.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 2000 + monthOffset,
          title: 'الأيام البيض 🌕',
          body: 'غدًا تبدأ الأيام البيض (13-14-15) – يُستحب الصيام',
          scheduledDate: reminderDate13,
        );
      }
    }
  }

  /// Schedule event reminders
  Future<void> _scheduleEventReminders() async {
    final today = HijriDate.now();
    final upcomingEvents = _eventsLoader.getUpcomingEvents(
      today.hDay,
      today.hMonth,
      today.hYear,
    );

    for (int i = 0; i < upcomingEvents.length && i < 10; i++) {
      final event = upcomingEvents[i];

      // Schedule reminder 1 day before
      // Note: HijriEvent stores year/month/day as integers
      // We need to convert it to Gregorian for scheduling
      final eventDate = HijriDate.fromHijri(
        event.year,
        event.month,
        event.day,
      ).toGregorian();

      final reminderDate = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        20,
        0,
      ).subtract(const Duration(days: 1));

      if (reminderDate.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: 3000 + i,
          title: 'مناسبة إسلامية قادمة 🌙',
          body: 'غدًا: ${event.title}',
          scheduledDate: reminderDate,
        );
      }
    }
  }

  /// Schedule Ramadan-specific reminders
  Future<void> _scheduleRamadanReminders() async {
    // Placeholder for Ramadan reminders
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Ignore errors for now
    }
  }

  /// Cancel all reminders
  Future<void> _cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

/// Background task callback
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'hijriReminderCheck') {
      try {
        // Re-schedule reminders
        await HijriNotificationService().scheduleAllReminders();
      } catch (e) {
        // Ignore
      }
    }
    return Future.value(true);
  });
}

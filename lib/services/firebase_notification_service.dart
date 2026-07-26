import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

// نموذج بيانات للإشعار المحفوظ
class NotificationMessage {
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String? deepLink;
  final String? category;

  NotificationMessage({
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    this.deepLink,
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'date': date.toIso8601String(),
    'isRead': isRead,
    'deepLink': deepLink,
    'category': category,
  };

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        date: DateTime.parse(json['date']),
        isRead: json['isRead'] ?? false,
        deepLink: json['deepLink'],
        category: json['category'],
      );
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  // ✅ آمن ولطيف: لا يفترض أن Firebase متصل دائماً
  FirebaseMessaging? get _messaging {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseMessaging.instance;
      }
    } catch (e) {
      debugPrint('FirebaseMessaging not available: $e');
    }
    return null;
  }

  // مفتاح التخزين
  static const String _storageKey = 'saved_notifications';

  // Stream for unread count
  final _unreadCountController = ValueNotifier<int>(0);
  ValueNotifier<int> get unreadCount => _unreadCountController;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      debugPrint('FCM is not supported on Windows Desktop.');
      return;
    }

    // تحديث العداد عند البدء فوراً (لا ينتظر الإذن)
    await _updateUnreadCount();

    final messaging = _messaging;
    if (messaging == null) {
      debugPrint('Firebase messaging is null or app not initialized.');
      return;
    }

    try {
      // ✅ تسجيل المستمعين فوراً بدون انتظار الإذن
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification Message opened app: ${message.data}');
        _handleNotificationClick(message);
      });

      // ✅ طلب الإذن في الخلفية (لا يعلّق الـ UI على iOS)
      _requestPermissionsInBackground();
    } catch (e) {
      debugPrint('Error initializing FCM listeners: $e');
    }
  }

  /// طلب الإذن في الخلفية حتى لا يعلّق التطبيق عند الفتح
  void _requestPermissionsInBackground() {
    Future.microtask(() async {
      try {
        final messaging = _messaging;
        if (messaging == null) return;

        // 1. طلب الإذن بشكل غير متزامن
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          debugPrint('FCM permission not granted');
          return;
        }

        debugPrint('FCM permission granted');

        // 2. الحصول على التوكين
        try {
          _fcmToken = await messaging.getToken();
          debugPrint('FCM Token: $_fcmToken');
          messaging.onTokenRefresh.listen((newToken) {
            _fcmToken = newToken;
          });
        } catch (e) {
          debugPrint('FCM Token error: $e');
        }

        // 3. الاشتراك في المواضيع
        await _subscribeToDefaultTopics();
      } catch (e) {
        debugPrint('FCM background init error: $e');
      }
    });
  }

  // الاشتراك في المواضيع الافتراضية
  Future<void> _subscribeToDefaultTopics() async {
    try {
      final messaging = _messaging;
      if (messaging == null) return;

      await messaging.subscribeToTopic('topic_ar_daily_quran');
      await messaging.subscribeToTopic('topic_ar_daily_hadith');
      await messaging.subscribeToTopic('topic_ar_daily_dhikr');
      await messaging.subscribeToTopic('topic_announcements');
    } catch (e) {
      debugPrint('Error subscribing to default topics: $e');
    }
  }

  // حفظ الإشعار في الذاكرة المحلية
  Future<void> _saveNotification(
    String title,
    String body, {
    String? deepLink,
    String? category,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList(_storageKey) ?? [];

      final newMessage = NotificationMessage(
        title: title,
        body: body,
        date: DateTime.now(),
        isRead: false,
        deepLink: deepLink,
        category: category,
      );

      savedList.insert(0, json.encode(newMessage.toJson()));
      await prefs.setStringList(_storageKey, savedList);
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  // تحديث عدد الرسائل غير المقروءة
  Future<void> _updateUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList(_storageKey) ?? [];
      int unread = 0;
      for (String item in savedList) {
        try {
          final map = json.decode(item);
          if (map['isRead'] == false) unread++;
        } catch (e) {
          // ignore broken JSON
        }
      }
      _unreadCountController.value = unread;
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  // جلب جميع الإشعارات المحفوظة
  Future<List<NotificationMessage>> getSavedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList(_storageKey) ?? [];
      return savedList
          .map((item) => NotificationMessage.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // تحديد الكل كـ "تمت القراءة"
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList(_storageKey) ?? [];
      List<String> updatedList = [];

      for (String item in savedList) {
        final map = json.decode(item);
        map['isRead'] = true;
        updatedList.add(json.encode(map));
      }

      await prefs.setStringList(_storageKey, updatedList);
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  // حذف جميع الإشعارات
  Future<void> clearNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await _updateUnreadCount();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  // التعامل مع الإشعار المستلم في Foreground
  void _handleForegroundMessage(RemoteMessage message) {
    String title = message.notification?.title ?? 'إشعار جديد';
    String body = message.notification?.body ?? '';
    String? deepLink = message.data['deepLink'];
    String? category = message.data['category'];

    _saveNotification(title, body, deepLink: deepLink, category: category);

    // إظهار الإشعار المحلي
    NotificationService().schedulePrayerNotification(
      DateTime.now().millisecond,
      title,
      body,
      DateTime.now().add(const Duration(seconds: 1)),
    );
  }

  // التعامل مع النقر على الإشعار
  void _handleNotificationClick(RemoteMessage message) {
    String title = message.notification?.title ?? 'إشعار جديد';
    String body = message.notification?.body ?? '';
    String? deepLink = message.data['deepLink'];
    String? category = message.data['category'];

    _saveNotification(title, body, deepLink: deepLink, category: category);
  }
}

import 'dart:convert';
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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

    // ✅ تسجيل المستمعين فوراً بدون انتظار الإذن
    // حتى لا يتوقف عرض التطبيق عند أول فتح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification Message opened app: ${message.data}');
      _handleNotificationClick(message);
    });

    // ✅ طلب الإذن في الخلفية (لا يعلّق الـ UI على iOS)
    _requestPermissionsInBackground();
  }

  /// طلب الإذن في الخلفية حتى لا يعلّق التطبيق عند الفتح
  void _requestPermissionsInBackground() {
    Future.microtask(() async {
      try {
        // 1. طلب الإذن بشكل غير متزامن
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission(
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
          _fcmToken = await _firebaseMessaging.getToken();
          debugPrint('FCM Token: $_fcmToken');
          _firebaseMessaging.onTokenRefresh.listen((newToken) {
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
      await _firebaseMessaging.subscribeToTopic('topic_ar_daily_quran');
      await _firebaseMessaging.subscribeToTopic('topic_ar_daily_hadith');
      await _firebaseMessaging.subscribeToTopic('topic_ar_daily_dhikr');
      await _firebaseMessaging.subscribeToTopic('topic_announcements');
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
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_storageKey) ?? [];

    final newMessage = NotificationMessage(
      title: title,
      body: body,
      date: DateTime.now(),
      deepLink: deepLink,
      category: category,
    );

    savedList.add(jsonEncode(newMessage.toJson()));
    await prefs.setStringList(_storageKey, savedList);

    // تحديث العداد
    await _updateUnreadCount();
  }

  // جلب كل الإشعارات المحفوظة
  Future<List<NotificationMessage>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_storageKey) ?? [];

    return savedList
        .map((item) => NotificationMessage.fromJson(jsonDecode(item)))
        .toList()
        .reversed // الأحدث أولاً
        .toList();
  }

  // تحديث عداد غير المقروء
  Future<void> _updateUnreadCount() async {
    final msgs = await getSavedNotifications();
    _unreadCountController.value = msgs.where((m) => !m.isRead).length;
  }

  // تعليم الكل كمقروء
  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_storageKey) ?? [];

    List<String> updatedList = savedList.map((item) {
      final json = jsonDecode(item);
      json['isRead'] = true;
      return jsonEncode(json);
    }).toList();

    await prefs.setStringList(_storageKey, updatedList);
    await _updateUnreadCount();
  }

  // مسح الإشعارات
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await _updateUnreadCount();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      final title = message.notification!.title ?? 'تنبيه';
      final body = message.notification!.body ?? '';
      final deepLink = message.data['deep_link'] ?? message.data['route'];
      final category = message.data['category'];

      // 1. عرض الإشعار محلياً (باستخدام خدمة الإشعارات الموجودة لدينا)
      NotificationService().schedulePrayerNotification(
        DateTime.now().millisecond, // ID عشوائي
        title,
        body,
        DateTime.now().add(const Duration(seconds: 1)), // جدولة فورية
      );

      // 2. حفظ الإشعار في الأرشيف
      _saveNotification(title, body, deepLink: deepLink, category: category);
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final title = message.notification?.title ?? 'تنبيه';
    final body = message.notification?.body ?? '';
    final deepLink = message.data['deep_link'] ?? message.data['route'];
    final category = message.data['category'];

    _saveNotification(title, body, deepLink: deepLink, category: category);
  }
}


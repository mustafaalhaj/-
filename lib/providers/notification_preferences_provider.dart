import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// المزود المسؤول عن حفظ وتحديث تفضيلات الإشعارات للمستخدم
class NotificationPreferencesProvider extends ChangeNotifier {
  static const String _prefFajrAdhan = 'pref_fajr_adhan';
  static const String _prefDhuhrAdhan = 'pref_dhuhr_adhan';
  static const String _prefAsrAdhan = 'pref_asr_adhan';
  static const String _prefMaghribAdhan = 'pref_maghrib_adhan';
  static const String _prefIshaAdhan = 'pref_isha_adhan';
  static const String _prefPrePrayerAlert = 'pref_pre_prayer_alert';
  static const String _prefPrePrayerMinutes = 'pref_pre_prayer_minutes';

  static const String _prefMorningAdhkar = 'pref_morning_adhkar';
  static const String _prefMorningHour = 'pref_morning_hour';
  static const String _prefMorningMinute = 'pref_morning_minute';

  static const String _prefEveningAdhkar = 'pref_evening_adhkar';
  static const String _prefEveningHour = 'pref_evening_hour';
  static const String _prefEveningMinute = 'pref_evening_minute';

  static const String _prefFridayKahf = 'pref_friday_kahf';
  static const String _prefQiyamLayl = 'pref_qiyam_layl';

  static const String _prefDailyQuranTopic = 'pref_topic_daily_quran';
  static const String _prefDailyHadithTopic = 'pref_topic_daily_hadith';
  static const String _prefDailyDhikrTopic = 'pref_topic_daily_dhikr';
  static const String _prefAnnouncementsTopic = 'pref_topic_announcements';

  // القيم المحلية
  bool _fajrAdhan = true;
  bool _dhuhrAdhan = true;
  bool _asrAdhan = true;
  bool _maghribAdhan = true;
  bool _ishaAdhan = true;
  bool _prePrayerAlert = false;
  int _prePrayerMinutes = 10;

  bool _morningAdhkar = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 30);

  bool _eveningAdhkar = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 16, minute: 30);

  bool _fridayKahf = true;
  bool _qiyamLayl = false;

  // القيم السحابية (FCM Topics)
  bool _dailyQuranTopic = true;
  bool _dailyHadithTopic = true;
  bool _dailyDhikrTopic = true;
  bool _announcementsTopic = true;

  bool _isLoading = true;

  // Getters
  bool get fajrAdhan => _fajrAdhan;
  bool get dhuhrAdhan => _dhuhrAdhan;
  bool get asrAdhan => _asrAdhan;
  bool get maghribAdhan => _maghribAdhan;
  bool get ishaAdhan => _ishaAdhan;
  bool get prePrayerAlert => _prePrayerAlert;
  int get prePrayerMinutes => _prePrayerMinutes;

  bool get morningAdhkar => _morningAdhkar;
  TimeOfDay get morningTime => _morningTime;

  bool get eveningAdhkar => _eveningAdhkar;
  TimeOfDay get eveningTime => _eveningTime;

  bool get fridayKahf => _fridayKahf;
  bool get qiyamLayl => _qiyamLayl;

  bool get dailyQuranTopic => _dailyQuranTopic;
  bool get dailyHadithTopic => _dailyHadithTopic;
  bool get dailyDhikrTopic => _dailyDhikrTopic;
  bool get announcementsTopic => _announcementsTopic;

  bool get isLoading => _isLoading;

  NotificationPreferencesProvider() {
    loadPreferences();
  }

  /// تحميل التفضيلات المخزنة
  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    _fajrAdhan = prefs.getBool(_prefFajrAdhan) ?? true;
    _dhuhrAdhan = prefs.getBool(_prefDhuhrAdhan) ?? true;
    _asrAdhan = prefs.getBool(_prefAsrAdhan) ?? true;
    _maghribAdhan = prefs.getBool(_prefMaghribAdhan) ?? true;
    _ishaAdhan = prefs.getBool(_prefIshaAdhan) ?? true;
    _prePrayerAlert = prefs.getBool(_prefPrePrayerAlert) ?? false;
    _prePrayerMinutes = prefs.getInt(_prefPrePrayerMinutes) ?? 10;

    _morningAdhkar = prefs.getBool(_prefMorningAdhkar) ?? true;
    final morningH = prefs.getInt(_prefMorningHour) ?? 6;
    final morningM = prefs.getInt(_prefMorningMinute) ?? 30;
    _morningTime = TimeOfDay(hour: morningH, minute: morningM);

    _eveningAdhkar = prefs.getBool(_prefEveningAdhkar) ?? true;
    final eveningH = prefs.getInt(_prefEveningHour) ?? 16;
    final eveningM = prefs.getInt(_prefEveningMinute) ?? 30;
    _eveningTime = TimeOfDay(hour: eveningH, minute: eveningM);

    _fridayKahf = prefs.getBool(_prefFridayKahf) ?? true;
    _qiyamLayl = prefs.getBool(_prefQiyamLayl) ?? false;

    _dailyQuranTopic = prefs.getBool(_prefDailyQuranTopic) ?? true;
    _dailyHadithTopic = prefs.getBool(_prefDailyHadithTopic) ?? true;
    _dailyDhikrTopic = prefs.getBool(_prefDailyDhikrTopic) ?? true;
    _announcementsTopic = prefs.getBool(_prefAnnouncementsTopic) ?? true;

    _isLoading = false;
    notifyListeners();
  }

  // --- Setters للصلوات والأذان ---
  Future<void> setPrayerAdhan(String prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    switch (prayer.toLowerCase()) {
      case 'fajr':
        _fajrAdhan = enabled;
        await prefs.setBool(_prefFajrAdhan, enabled);
        break;
      case 'dhuhr':
        _dhuhrAdhan = enabled;
        await prefs.setBool(_prefDhuhrAdhan, enabled);
        break;
      case 'asr':
        _asrAdhan = enabled;
        await prefs.setBool(_prefAsrAdhan, enabled);
        break;
      case 'maghrib':
        _maghribAdhan = enabled;
        await prefs.setBool(_prefMaghribAdhan, enabled);
        break;
      case 'isha':
        _ishaAdhan = enabled;
        await prefs.setBool(_prefIshaAdhan, enabled);
        break;
    }
    notifyListeners();
  }

  Future<void> setPrePrayerAlert(bool enabled, {int? minutes}) async {
    final prefs = await SharedPreferences.getInstance();
    _prePrayerAlert = enabled;
    await prefs.setBool(_prefPrePrayerAlert, enabled);
    if (minutes != null) {
      _prePrayerMinutes = minutes;
      await prefs.setInt(_prefPrePrayerMinutes, minutes);
    }
    notifyListeners();
  }

  // --- Setters للأذكار والتنبيهات المحلية ---
  Future<void> setMorningAdhkar(bool enabled, {TimeOfDay? time}) async {
    final prefs = await SharedPreferences.getInstance();
    _morningAdhkar = enabled;
    await prefs.setBool(_prefMorningAdhkar, enabled);
    if (time != null) {
      _morningTime = time;
      await prefs.setInt(_prefMorningHour, time.hour);
      await prefs.setInt(_prefMorningMinute, time.minute);
    }
    notifyListeners();
  }

  Future<void> setEveningAdhkar(bool enabled, {TimeOfDay? time}) async {
    final prefs = await SharedPreferences.getInstance();
    _eveningAdhkar = enabled;
    await prefs.setBool(_prefEveningAdhkar, enabled);
    if (time != null) {
      _eveningTime = time;
      await prefs.setInt(_prefEveningHour, time.hour);
      await prefs.setInt(_prefEveningMinute, time.minute);
    }
    notifyListeners();
  }

  Future<void> setFridayKahf(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _fridayKahf = enabled;
    await prefs.setBool(_prefFridayKahf, enabled);
    notifyListeners();
  }

  Future<void> setQiyamLayl(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _qiyamLayl = enabled;
    await prefs.setBool(_prefQiyamLayl, enabled);
    notifyListeners();
  }

  // --- Setters لمواضيع FCM السحابية (FCM Topics Sync) ---
  Future<void> setTopicSubscription(String topicKey, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    String topicName = '';

    switch (topicKey) {
      case 'daily_quran':
        _dailyQuranTopic = enabled;
        await prefs.setBool(_prefDailyQuranTopic, enabled);
        topicName = 'topic_ar_daily_quran';
        break;
      case 'daily_hadith':
        _dailyHadithTopic = enabled;
        await prefs.setBool(_prefDailyHadithTopic, enabled);
        topicName = 'topic_ar_daily_hadith';
        break;
      case 'daily_dhikr':
        _dailyDhikrTopic = enabled;
        await prefs.setBool(_prefDailyDhikrTopic, enabled);
        topicName = 'topic_ar_daily_dhikr';
        break;
      case 'announcements':
        _announcementsTopic = enabled;
        await prefs.setBool(_prefAnnouncementsTopic, enabled);
        topicName = 'topic_announcements';
        break;
    }

    notifyListeners();

    // مزامنة الاشتراك مع Firebase Messaging
    try {
      if (enabled) {
        await FirebaseMessaging.instance.subscribeToTopic(topicName);
        debugPrint('Subscribed to FCM topic: $topicName');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
        debugPrint('Unsubscribed from FCM topic: $topicName');
      }
    } catch (e) {
      debugPrint('Error updating FCM topic $topicName: $e');
    }
  }
}

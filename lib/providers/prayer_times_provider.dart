import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';

class PrayerTimesProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  PrayerTimes? get prayerTimes => _prayerTimes;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _locationName = 'جاري تحديد الموقع...';
  String get locationName => _locationName;

  // Settings
  bool _autoDetect = true;
  bool get autoDetect => _autoDetect;

  CalculationMethod _method = CalculationMethod.muslim_world_league;
  CalculationMethod get method => _method;

  Madhab _madhab = Madhab.shafi;
  Madhab get madhab => _madhab;

  // Manual offsets (in minutes)
  Map<Prayer, int> _offsets = {
    Prayer.fajr: 0,
    Prayer.sunrise: 0,
    Prayer.dhuhr: 0,
    Prayer.asr: 0,
    Prayer.maghrib: 0,
    Prayer.isha: 0,
  };
  Map<Prayer, int> get offsets => _offsets;

  bool _highLatitudeAdjustment = false;
  bool get highLatitudeAdjustment => _highLatitudeAdjustment;

  PrayerTimesProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _autoDetect = prefs.getBool('pt_auto_detect') ?? true;
    final methodIndex = prefs.getInt('pt_method') ?? 0;
    final madhabIndex = prefs.getInt('pt_madhab') ?? 0;
    final highLat = prefs.getBool('pt_high_lat') ?? false;

    // Load Offsets
    _offsets = {
      Prayer.fajr: prefs.getInt('off_fajr') ?? 0,
      Prayer.sunrise: prefs.getInt('off_sunrise') ?? 0,
      Prayer.dhuhr: prefs.getInt('off_dhuhr') ?? 0,
      Prayer.asr: prefs.getInt('off_asr') ?? 0,
      Prayer.maghrib: prefs.getInt('off_maghrib') ?? 0,
      Prayer.isha: prefs.getInt('off_isha') ?? 0,
    };

    _method = _getMethodFromIndex(methodIndex);
    _madhab = madhabIndex == 1 ? Madhab.hanafi : Madhab.shafi;
    _highLatitudeAdjustment = highLat;

    notifyListeners();
    fetchPrayerTimes();
  }

  CalculationMethod _getMethodFromIndex(int index) {
    switch (index) {
      case 1:
        return CalculationMethod.egyptian;
      case 2:
        return CalculationMethod.karachi;
      case 3:
        return CalculationMethod.umm_al_qura;
      case 4:
        return CalculationMethod.dubai;
      case 5:
        return CalculationMethod.qatar;
      case 6:
        return CalculationMethod.kuwait;
      case 8:
        return CalculationMethod.singapore;
      case 9:
        return CalculationMethod.turkey;
      case 10:
        return CalculationMethod.tehran;
      case 11:
        return CalculationMethod.north_america;
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  int _getIndexFromMethod(CalculationMethod method) {
    if (method == CalculationMethod.egyptian) return 1;
    if (method == CalculationMethod.karachi) return 2;
    if (method == CalculationMethod.umm_al_qura) return 3;
    if (method == CalculationMethod.dubai) return 4;
    if (method == CalculationMethod.qatar) return 5;
    if (method == CalculationMethod.kuwait) return 6;
    if (method == CalculationMethod.singapore) return 8;
    if (method == CalculationMethod.turkey) return 9;
    if (method == CalculationMethod.tehran) return 10;
    if (method == CalculationMethod.north_america) return 11;
    return 0; // MWL
  }

  Future<void> updateSettings({
    bool? autoDetect,
    CalculationMethod? method,
    Madhab? madhab,
    Map<Prayer, int>? offsets,
    bool? highLatitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (autoDetect != null) {
      _autoDetect = autoDetect;
      await prefs.setBool('pt_auto_detect', autoDetect);
    }

    if (method != null) {
      _method = method;
      await prefs.setInt('pt_method', _getIndexFromMethod(method));
    }

    if (madhab != null) {
      _madhab = madhab;
      await prefs.setInt('pt_madhab', madhab == Madhab.hanafi ? 1 : 0);
    }

    if (offsets != null) {
      _offsets = offsets;
      await prefs.setInt('off_fajr', offsets[Prayer.fajr] ?? 0);
      await prefs.setInt('off_sunrise', offsets[Prayer.sunrise] ?? 0);
      await prefs.setInt('off_dhuhr', offsets[Prayer.dhuhr] ?? 0);
      await prefs.setInt('off_asr', offsets[Prayer.asr] ?? 0);
      await prefs.setInt('off_maghrib', offsets[Prayer.maghrib] ?? 0);
      await prefs.setInt('off_isha', offsets[Prayer.isha] ?? 0);
    }

    if (highLatitude != null) {
      _highLatitudeAdjustment = highLatitude;
      await prefs.setBool('pt_high_lat', highLatitude);
    }

    notifyListeners();
    fetchPrayerTimes(); // Refresh calculation
  }

  void _detectAutoSettings(Placemark place) {
    final country = place.isoCountryCode?.toUpperCase() ?? '';

    // Default to MWL
    CalculationMethod newMethod = CalculationMethod.muslim_world_league;
    Madhab newMadhab = Madhab.shafi;

    if (['EG', 'SD', 'LY', 'DZ', 'TN', 'MA'].contains(country)) {
      // North Africa
      newMethod = CalculationMethod.egyptian;
    } else if ([
      'SA',
      'KW',
      'AE',
      'QA',
      'BH',
      'OM',
      'YE',
      'IQ',
      'JO',
      'SY',
      'LB',
      'PS',
      'IR',
      'PK',
    ].contains(country)) {
      // Gulf & Asia
      newMethod = CalculationMethod.umm_al_qura;
      if (['PK', 'AF', 'IN', 'BD'].contains(country)) {
        newMethod = CalculationMethod.karachi;
        newMadhab = Madhab.hanafi;
      } else if (['TR'].contains(country)) {
        newMethod = CalculationMethod.turkey;
        newMadhab = Madhab.hanafi;
      }
    } else if (country == 'TR') {
      newMethod = CalculationMethod.turkey;
      newMadhab = Madhab.hanafi;
    } else if (['US', 'CA'].contains(country)) {
      newMethod = CalculationMethod.north_america;
    } else if (['SG', 'MY', 'ID'].contains(country)) {
      newMethod = CalculationMethod.singapore;
    } else if ([
      'GB',
      'FR',
      'DE',
      'IT',
      'ES',
      'NL',
      'BE',
      'SE',
      'NO',
      'DK',
    ].contains(country)) {
      // Europe -> MWL (or other standard if preferred)
      newMethod = CalculationMethod.muslim_world_league;
    }

    _method = newMethod;
    _madhab = newMadhab;

    // Save detected settings
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('pt_method', _getIndexFromMethod(_method));
      prefs.setInt('pt_madhab', _madhab == Madhab.hanafi ? 1 : 0);
    });
  }

  Future<void> fetchPrayerTimes() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Position? position;
      try {
        position = await _locationService.determinePosition();
      } catch (e) {
        // Location disabled or denied
      }

      Coordinates coordinates;
      if (position != null) {
        coordinates = Coordinates(position.latitude, position.longitude);

        final place = await _locationService.getPlacemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (place != null) {
          _locationName = '${place.locality}, ${place.country}';
          if (_autoDetect) {
            _detectAutoSettings(place);
          }
        } else {
          _locationName = 'موقعك الحالي';
        }
      } else {
        // Fallback to Mecca
        coordinates = Coordinates(21.4225, 39.8262);
        _locationName = 'مكة المكرمة (افتراضي)';
      }

      final params = _method.getParameters();
      params.madhab = _madhab;

      if (_highLatitudeAdjustment) {
        params.highLatitudeRule = HighLatitudeRule.seventh_of_the_night;
      }

      // Apply offsets
      params.adjustments.fajr = _offsets[Prayer.fajr] ?? 0;
      params.adjustments.sunrise = _offsets[Prayer.sunrise] ?? 0;
      params.adjustments.dhuhr = _offsets[Prayer.dhuhr] ?? 0;
      params.adjustments.asr = _offsets[Prayer.asr] ?? 0;
      params.adjustments.maghrib = _offsets[Prayer.maghrib] ?? 0;
      params.adjustments.isha = _offsets[Prayer.isha] ?? 0;

      final today = DateTime.now();
      _prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(today),
        params,
      );

      try {
        await _scheduleNotifications();
      } catch (e) {
        debugPrint('Schedule notifications skipped: $e');
      }

      try {
        await _updateHomeWidget();
      } catch (e) {
        debugPrint('Update home widget skipped: $e');
      }
    } catch (e) {
      _errorMessage = 'تعذر حساب المواقيت: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _scheduleNotifications() async {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    await _notificationService.cancelAllNotifications();

    int id = 0;

    // 1. جدولة صلوات اليوم المتبقية
    final todayPrayers = {
      'الفجر': _prayerTimes!.fajr,
      'الظهر': _prayerTimes!.dhuhr,
      'العصر': _prayerTimes!.asr,
      'المغرب': _prayerTimes!.maghrib,
      'العشاء': _prayerTimes!.isha,
    };

    todayPrayers.forEach((name, time) {
      if (time.isAfter(now)) {
        _notificationService.schedulePrayerNotification(
          id++,
          'الله أكبر - حان وقت الصلاة',
          'حان الآن موعد صلاة $name',
          time,
        );
      }
    });

    // 2. حساب وجدولة صلوات الغد لضمان التنبيه المستمر في الخلفية
    try {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayerTimes = PrayerTimes(
        _prayerTimes!.coordinates,
        DateComponents.from(tomorrow),
        _prayerTimes!.calculationParameters,
      );

      final tomorrowPrayers = {
        'الفجر': tomorrowPrayerTimes.fajr,
        'الظهر': tomorrowPrayerTimes.dhuhr,
        'العصر': tomorrowPrayerTimes.asr,
        'المغرب': tomorrowPrayerTimes.maghrib,
        'العشاء': tomorrowPrayerTimes.isha,
      };

      tomorrowPrayers.forEach((name, time) {
        if (time.isAfter(now)) {
          _notificationService.schedulePrayerNotification(
            id++,
            'الله أكبر - حان وقت الصلاة',
            'حان الآن موعد صلاة $name',
            time,
          );
        }
      });
    } catch (e) {
      debugPrint('Error scheduling tomorrow prayer notifications: $e');
    }
  }

  Future<void> _updateHomeWidget() async {
    if (_prayerTimes == null) return;

    final next = _prayerTimes!.nextPrayer();
    String nextName = '';
    String nextTime = '';

    if (next != Prayer.none) {
      nextName = _getPrayerName(next);
      final dt = _prayerTimes!.timeForPrayer(next);
      if (dt != null) {
        nextTime = DateFormat.jm('ar').format(dt);
      }
    } else {
      nextName = 'الفجر';
      // Approximation for tomorrow's Fajr if needed, or just show today's logic
      // Ideally we calculate tomorrow's prayer times
      nextTime = 'غداً';
    }

    await HomeWidgetService.updatePrayerWidget(
      title: 'الصلاة القادمة',
      nextPrayerName: nextName,
      nextPrayerTime: nextTime,
      location: _locationName,
    );
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return '';
    }
  }
}

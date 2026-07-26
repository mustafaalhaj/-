import 'package:hijri/hijri_calendar.dart';

/// Wrapper class for Hijri date to provide consistent API
class HijriDate {
  final HijriCalendar _hijri;

  HijriDate._(this._hijri);

  /// Create from current date
  factory HijriDate.now() {
    return HijriDate._(HijriCalendar.now());
  }

  /// Create from Gregorian date
  factory HijriDate.fromGregorian(DateTime date) {
    return HijriDate._(HijriCalendar.fromDate(date));
  }

  /// Create from Hijri date components
  factory HijriDate.fromHijri(int year, int month, int day) {
    final hijri = HijriCalendar();
    hijri.hYear = year;
    hijri.hMonth = month;
    hijri.hDay = day;
    return HijriDate._(hijri);
  }

  /// Get Hijri day
  int get hDay => _hijri.hDay;

  /// Get Hijri month
  int get hMonth => _hijri.hMonth;

  /// Get Hijri year
  int get hYear => _hijri.hYear;

  /// Get weekday (1 = Monday, 7 = Sunday)
  int get wkDay => _hijri.wkDay ?? 1;

  /// Set Hijri day
  set hDay(int value) => _hijri.hDay = value;

  /// Set Hijri month
  set hMonth(int value) => _hijri.hMonth = value;

  /// Set Hijri year
  set hYear(int value) => _hijri.hYear = value;

  /// Convert to Gregorian date
  DateTime toGregorian() {
    return _hijri.hijriToGregorian(hYear, hMonth, hDay);
  }

  /// Get length of current Hijri month
  int get lengthOfMonth => _hijri.lengthOfMonth;

  /// Get month name in Arabic
  String get monthName {
    const monthNames = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الثانية',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    // Ensure index is valid
    final index = hMonth - 1;
    if (index >= 0 && index < monthNames.length) {
      return monthNames[index];
    }
    return '';
  }

  /// Get weekday name in Arabic
  String get weekdayName {
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    // Ensure index is valid
    final index = wkDay - 1;
    if (index >= 0 && index < weekdays.length) {
      return weekdays[index];
    }
    return '';
  }

  /// Add days to the date
  HijriDate addDays(int days) {
    final gregorian = toGregorian().add(Duration(days: days));
    return HijriDate.fromGregorian(gregorian);
  }

  /// Subtract days from the date
  HijriDate subtractDays(int days) {
    final gregorian = toGregorian().subtract(Duration(days: days));
    return HijriDate.fromGregorian(gregorian);
  }

  /// Check if two dates are equal
  bool isEqual(HijriDate other) {
    return hDay == other.hDay && hMonth == other.hMonth && hYear == other.hYear;
  }

  /// Get formatted string
  String format() {
    return '$hDay $monthName $hYear';
  }

  @override
  String toString() => format();
}

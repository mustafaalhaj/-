import 'hijri_date.dart';
import 'hijri_event.dart';

/// Model representing a single day in the Hijri calendar
class HijriDay {
  final HijriDate date;
  final bool isToday;
  final bool isMonday;
  final bool isThursday;
  final bool isWhiteDay; // الأيام البيض (13, 14, 15)
  final HijriEvent? event;
  final bool isCurrentMonth;

  const HijriDay({
    required this.date,
    this.isToday = false,
    this.isMonday = false,
    this.isThursday = false,
    this.isWhiteDay = false,
    this.event,
    this.isCurrentMonth = true,
  });

  /// Check if this day is recommended for fasting
  bool get isRecommendedFasting {
    return isMonday || isThursday || isWhiteDay;
  }

  /// Get the day number
  int get day => date.hDay;

  /// Get the month number
  int get month => date.hMonth;

  /// Get the year number
  int get year => date.hYear;

  /// Get weekday name in Arabic
  String get weekdayName => date.weekdayName;

  /// Copy with method
  HijriDay copyWith({
    HijriDate? date,
    bool? isToday,
    bool? isMonday,
    bool? isThursday,
    bool? isWhiteDay,
    HijriEvent? event,
    bool? isCurrentMonth,
  }) {
    return HijriDay(
      date: date ?? this.date,
      isToday: isToday ?? this.isToday,
      isMonday: isMonday ?? this.isMonday,
      isThursday: isThursday ?? this.isThursday,
      isWhiteDay: isWhiteDay ?? this.isWhiteDay,
      event: event ?? this.event,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
    );
  }
}

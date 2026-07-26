import 'hijri_date.dart';

enum EventType {
  eid,
  ramadan,
  specialNight, // Laylat al-Qadr, etc.
  fastingDay, // Ashura, Arafah
  occasion, // General occasions
}

class HijriEvent {
  final String title;
  final int day;
  final int month;
  final int year;
  final EventType type;

  const HijriEvent({
    required this.title,
    required this.day,
    required this.month,
    required this.year,
    required this.type,
  });

  /// Create HijriEvent from JSON
  factory HijriEvent.fromJson(
    Map<String, dynamic> json,
    int day,
    int month,
    int year,
  ) {
    return HijriEvent(
      title: json['title'] as String,
      day: day,
      month: month,
      year: year,
      type: _determineEventType(json['title'] as String, day, month),
    );
  }

  /// Helper to determine event type from title/date
  static EventType _determineEventType(String title, int day, int month) {
    if (title.contains('عيد') || title.contains('Eid')) {
      return EventType.eid;
    } else if (title.contains('رمضان') || month == 9) {
      return EventType.ramadan;
    } else if (title.contains('عرفة') || title.contains('عاشوراء')) {
      return EventType.fastingDay;
    } else if (title.contains('الليلة') || title.contains('ليلة')) {
      return EventType.specialNight;
    } else {
      return EventType.occasion;
    }
  }

  /// Check if event is upcoming relative to current date
  bool isUpcoming(int currentDay, int currentMonth, int currentYear) {
    if (year > currentYear) return true;
    if (year == currentYear) {
      if (month > currentMonth) return true;
      if (month == currentMonth && day >= currentDay) return true;
    }
    return false;
  }

  /// Calculate days until this event
  int daysUntil(int currentDay, int currentMonth, int currentYear) {
    final now = HijriDate.fromHijri(
      currentYear,
      currentMonth,
      currentDay,
    ).toGregorian();
    final eventDate = HijriDate.fromHijri(year, month, day).toGregorian();

    return eventDate.difference(now).inDays;
  }
}

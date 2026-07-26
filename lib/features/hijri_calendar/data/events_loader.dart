import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/services.dart';
import '../domain/models/hijri_event.dart';

class EventsLoader {
  static EventsLoader? _instance;
  Map<String, dynamic>? _eventsData;

  EventsLoader._();

  factory EventsLoader() {
    _instance ??= EventsLoader._();
    return _instance!;
  }

  /// Load events from assets
  Future<void> loadEvents() async {
    if (_eventsData != null) return; // Already loaded

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/calendar/events.json',
      );
      _eventsData = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading events: $e');
      _eventsData = {}; // Empty map on error
    }
  }

  /// Get event for a specific date
  HijriEvent? getEvent(int day, int month, int year) {
    if (_eventsData == null) return null;

    try {
      final yearData = _eventsData![year.toString()] as Map<String, dynamic>?;
      if (yearData == null) return null;

      final monthData = yearData[month.toString()] as Map<String, dynamic>?;
      if (monthData == null) return null;

      final eventTitle = monthData[day.toString()] as String?;
      if (eventTitle == null) return null;

      return HijriEvent.fromJson({'title': eventTitle}, day, month, year);
    } catch (e) {
      debugPrint('Error getting event: $e');
      return null;
    }
  }

  /// Get all events for a specific month
  List<HijriEvent> getMonthEvents(int month, int year) {
    if (_eventsData == null) return [];

    try {
      final yearData = _eventsData![year.toString()] as Map<String, dynamic>?;
      if (yearData == null) return [];

      final monthData = yearData[month.toString()] as Map<String, dynamic>?;
      if (monthData == null) return [];

      final events = <HijriEvent>[];
      monthData.forEach((dayStr, title) {
        final day = int.tryParse(dayStr);
        if (day != null && title is String) {
          events.add(HijriEvent.fromJson({'title': title}, day, month, year));
        }
      });

      // Sort by day
      events.sort((a, b) => a.day.compareTo(b.day));
      return events;
    } catch (e) {
      debugPrint('Error getting month events: $e');
      return [];
    }
  }

  /// Get upcoming events (next 30 days)
  List<HijriEvent> getUpcomingEvents(
    int currentDay,
    int currentMonth,
    int currentYear,
  ) {
    if (_eventsData == null) return [];

    final allEvents = <HijriEvent>[];

    // Get events from current month and next 2 months
    for (int i = 0; i < 3; i++) {
      int targetMonth = currentMonth + i;
      int targetYear = currentYear;

      if (targetMonth > 12) {
        targetMonth -= 12;
        targetYear++;
      }

      allEvents.addAll(getMonthEvents(targetMonth, targetYear));
    }

    // Filter upcoming events only
    final upcoming = allEvents.where((event) {
      return event.isUpcoming(currentDay, currentMonth, currentYear);
    }).toList();

    // Sort by date
    upcoming.sort((a, b) {
      final aDays = a.daysUntil(currentDay, currentMonth, currentYear);
      final bDays = b.daysUntil(currentDay, currentMonth, currentYear);
      return aDays.compareTo(bDays);
    });

    return upcoming.take(5).toList(); // Return next 5 events
  }
}

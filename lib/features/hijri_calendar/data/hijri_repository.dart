import '../domain/models/hijri_date.dart';
import '../domain/models/hijri_day.dart';
import 'events_loader.dart';

class HijriRepository {
  final EventsLoader _eventsLoader = EventsLoader();

  Future<void> initialize() async {
    await _eventsLoader.loadEvents();
  }

  /// Check if it's currently Ramadan
  bool isRamadan() {
    return HijriDate.now().hMonth == 9;
  }

  /// Get days for a specific Hijri month to build the calendar grid
  List<HijriDay> getMonthDays(int month, int year) {
    final days = <HijriDay>[];
    final today = HijriDate.now();

    // Get the first day of the month
    final firstDay = HijriDate.fromHijri(year, month, 1);

    // Get number of days in the month
    final daysInMonth = firstDay.lengthOfMonth;

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDay.wkDay;

    // Add empty days for previous month to align the grid
    // HijriDate.wkDay returns 1 for Monday...7 for Sunday.
    // If we start the week on Sunday (usual in Arab world?), we need alignment.
    // Assuming standard calendar starting Sunday.
    // The previous implementation used standard logic. Let's adjust.
    // If standard week starts on Sunday (7), map Monday(1) to 1, etc.
    // Actually, usually calendars start Sunday or Monday.
    // Let's assume Week starts on Sunday => Sunday = 0, Monday = 1...
    // HijriCalendar.wkDay: 1=Mon, 7=Sun.
    // So if 1st day is Mon(1), we need 1 empty cell (Sun).
    // If 1st day is Sun(7), we need 0 empty cells.

    // Calculate empty offset
    // Sun=0, Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6
    // wkDay: Mon=1...Sun=7
    // offset = wkDay % 7 ? No.
    // Map: Sun->0, Mon->1 ... Sat->6
    // 7 -> 0, 1 -> 1, 2 -> 2...
    final offset = firstWeekday == 7 ? 0 : firstWeekday;

    for (int i = 0; i < offset; i++) {
      // Just fill with "previous month" placeholder logic
      // For simplicity in display, we usually want the exact date.
      // We can subtract days from firstDay.
      final prevDayDate = firstDay.subtractDays(offset - i);
      days.add(HijriDay(date: prevDayDate, isCurrentMonth: false));
    }

    // Add days of current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = HijriDate.fromHijri(year, month, day);

      final isToday =
          date.hDay == today.hDay &&
          date.hMonth == today.hMonth &&
          date.hYear == today.hYear;

      final weekday = date.wkDay;
      final isMonday = weekday == 1; // Mon
      final isThursday = weekday == 4; // Thu
      final isWhiteDay = day == 13 || day == 14 || day == 15;

      // Get event for this day
      final event = _eventsLoader.getEvent(day, month, year);

      days.add(
        HijriDay(
          date: date,
          isToday: isToday,
          isMonday: isMonday,
          isThursday: isThursday,
          isWhiteDay: isWhiteDay,
          event: event,
          isCurrentMonth: true,
        ),
      );
    }

    // Fill remaining cells with next month days (grid usually has 35 or 42 cells)
    final remainingCells = 42 - days.length; // 6 rows * 7 columns
    final lastDay = HijriDate.fromHijri(year, month, daysInMonth);

    for (int i = 1; i <= remainingCells; i++) {
      final nextMonthDay = lastDay.addDays(i);
      days.add(HijriDay(date: nextMonthDay, isCurrentMonth: false));
    }

    return days;
  }
}

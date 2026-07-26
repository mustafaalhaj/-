import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'PrayerWidgetProvider';

  static Future<void> updatePrayerWidget({
    required String title,
    required String nextPrayerName,
    required String nextPrayerTime,
    required String location,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('widget_title', title);
      await HomeWidget.saveWidgetData<String>(
        'widget_prayer_name',
        nextPrayerName,
      );
      await HomeWidget.saveWidgetData<String>('widget_time', nextPrayerTime);
      await HomeWidget.saveWidgetData<String>('widget_location', location);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        iOSName: 'PrayerWidget', // Matches iOS widget name if we had one
        qualifiedAndroidName:
            'com.alhajmustafaana.anamuslim.PrayerWidgetProvider',
      );

      debugPrint(
        'Widget updated successfully: $nextPrayerName at $nextPrayerTime',
      );
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }
}

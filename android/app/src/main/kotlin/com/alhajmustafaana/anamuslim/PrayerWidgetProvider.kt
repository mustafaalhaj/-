package com.alhajmustafaana.anamuslim

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.alhajmustafaana.anamuslim.R

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray,
            widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views =
                    RemoteViews(context.packageName, R.layout.widget_layout).apply {
                        val title = widgetData.getString("widget_title", "الصلاة القادمة")
                        val prayerName = widgetData.getString("widget_prayer_name", "--")
                        val time = widgetData.getString("widget_time", "--:--")
                        val location = widgetData.getString("widget_location", "...")

                        setTextViewText(R.id.widget_title, title)
                        setTextViewText(R.id.widget_prayer_name, prayerName)
                        setTextViewText(R.id.widget_time, time)
                        setTextViewText(R.id.widget_location, location)
                    }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

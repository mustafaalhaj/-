// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../domain/models/hijri_day.dart';
import '../domain/models/hijri_event.dart';

/// Widget to display a single day tile in the calendar
class HijriDayTile extends StatelessWidget {
  final HijriDay day;
  final VoidCallback? onTap;

  const HijriDayTile({super.key, required this.day, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getGradient(isDark),
          border: day.isToday
              ? Border.all(
                  color: const Color(0xFFFFD700), // Golden border for today
                  width: 2,
                )
              : null,
          boxShadow: day.isToday
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Day number
            Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
                  color: day.isCurrentMonth
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ),

            // Event indicator (top)
            if (day.event != null)
              Positioned(
                top: 4,
                right: 4,
                child: _EventIcon(type: day.event!.type),
              ),

            // Fasting indicator (bottom)
            if (day.isRecommendedFasting && day.isCurrentMonth)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: day.isWhiteDay
                          ? const Color(0xFFFFD700) // Gold for white days
                          : Colors.green, // Green for Monday/Thursday
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient? _getGradient(bool isDark) {
    if (day.isToday) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF009688).withOpacity(0.3),
                const Color(0xFF004D40).withOpacity(0.3),
              ]
            : [
                const Color(0xFF80CBC4).withOpacity(0.3),
                const Color(0xFF4DB6AC).withOpacity(0.3),
              ],
      );
    }

    if (!day.isCurrentMonth) {
      return null;
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
          : [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.5)],
    );
  }
}

/// Icon widget for event types
class _EventIcon extends StatelessWidget {
  final EventType type;

  const _EventIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case EventType.eid:
        return Icons.celebration;
      case EventType.ramadan:
        return Icons.nightlight_round;
      case EventType.specialNight:
        return Icons.star;
      case EventType.fastingDay:
        return Icons.restaurant;
      case EventType.occasion:
        return Icons.event;
    }
  }

  Color _getColor() {
    switch (type) {
      case EventType.eid:
        return const Color(0xFFFFD700); // Gold
      case EventType.ramadan:
        return const Color(0xFF9C27B0); // Purple
      case EventType.specialNight:
        return const Color(0xFFFFD700); // Gold
      case EventType.fastingDay:
        return Colors.green;
      case EventType.occasion:
        return const Color(0xFF009688); // Teal
    }
  }
}

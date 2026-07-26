import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const GlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.transparent, // Important for shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.2,
            ), // Soft shadow behind the bar
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.8)
              : primaryColor.withValues(alpha: 0.9), // Dynamic Background
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, Icons.menu_book_rounded, "القرآن الكريم"),
            _buildNavItem(
              context,
              1,
              Icons.access_time_filled_rounded,
              "المواقيت",
            ),
            _buildNavItem(
              context,
              2,
              Icons.home_rounded,
              "الرئيسية",
              isCenter: true,
            ),
            _buildNavItem(
              context,
              3,
              Icons.volunteer_activism_rounded,
              "الأذكار",
            ),
            _buildNavItem(context, 4, Icons.apps_rounded, "المزيد"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    bool isCenter = false,
  }) {
    final isSelected = selectedIndex == index;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final color = isSelected
        ? secondaryColor
        : Colors.white.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: isCenter && isSelected
                ? BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Icon(icon, color: color, size: isCenter ? 32 : 24),
          ),
          if (!isCenter)
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}

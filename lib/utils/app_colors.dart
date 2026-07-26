import 'package:flutter/material.dart';

/// نظام الألوان الموحد للتطبيق
/// ثيم إسلامي راقي (Turquoise + Gold)
class AppColors {
  // ==================== Primary Colors ====================

  // Turquoise/Teal - اللون الرئيسي
  static const Color primary = Color(0xFF009688);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color primaryContainer = Color(0xFFB2DFDB);

  // Gold/Amber - اللون الثانوي
  static const Color secondary = Color(0xFFFFAB00);
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFFF8F00);
  static const Color secondaryContainer = Color(0xFFFFECB3);

  // ==================== Surface Colors ====================

  // Light Theme
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark Theme
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF2C2C2C);

  // ==================== Text Colors ====================

  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // ==================== Semantic Colors ====================

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ==================== Islamic Theme Colors ====================

  // للقرآن الكريم
  static const Color quranGreen = Color(0xFF1B5E20);
  static const Color quranGold = Color(0xFFD4AF37);
  static const Color quranBeige = Color(0xFFF5E6D3);

  // للصلاة
  static const Color prayerBlue = Color(0xFF1565C0);
  static const Color prayerSky = Color(0xFF4FC3F7);

  // للأذكار
  static const Color adhkarTeal = Color(0xFF00897B);
  static const Color adhkarMint = Color(0xFF80CBC4);

  // للحديث
  static const Color hadithBrown = Color(0xFF5D4037);
  static const Color hadithTan = Color(0xFFBCAAA4);

  // ==================== Gradients ====================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient quranGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [quranGreen, Color(0xFF2E7D32)],
  );

  static const LinearGradient prayerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [prayerBlue, prayerSky],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  // ==================== Preset Gradients ====================

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFE6B8B), Color(0xFFFF8E53)],
  );

  static const LinearGradient fajrGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2980B9), Color(0xFF6DD5FA), Color(0xFFFFFFFF)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF141E30), Color(0xFF243B55)],
  );

  static const LinearGradient royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF536976), Color(0xFF292E49)],
  );

  // Note: Gold Gradient already exists as 'goldGradient' below

  static LinearGradient glassGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ]
        : [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.6),
          ],
  );

  // Helper to get gradient by name
  static LinearGradient getGradient(String name) {
    switch (name) {
      case 'sunset':
        return sunsetGradient;
      case 'fajr':
        return fajrGradient;
      case 'night':
        return nightGradient;
      case 'royal':
        return royalGradient;
      case 'gold':
      default:
        return goldGradient;
    }
  }

  // ==================== Utility Methods ====================

  /// الحصول على ColorScheme للـ Light Theme
  static ColorScheme getLightColorScheme() {
    return const ColorScheme.light(
      primary: primary,
      primaryContainer: primaryContainer,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      surface: surfaceLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      onError: Colors.white,
    );
  }

  /// الحصول على ColorScheme للـ Dark Theme
  static ColorScheme getDarkColorScheme() {
    return const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryDark,
      secondary: secondaryLight,
      secondaryContainer: secondaryDark,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      onError: Colors.white,
    );
  }

  /// Shadow للـ Cards
  static List<BoxShadow> cardShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Shadow ناعم
  static List<BoxShadow> softShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Neumorphic Shadow
  static List<BoxShadow> neumorphicShadow(bool isDark) {
    return isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
          ];
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام Typography موحد للتطبيق
/// يدعم 3 لغات: عربي، إنجليزي، فرنسي
class AppTextStyles {
  // ==================== عربي (Cairo) ====================

  // Headers - العناوين
  static TextStyle headlineLargeAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.6,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineMediumAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineSmallAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Body - النصوص العادية
  static TextStyle bodyLargeAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.8,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMediumAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.7,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmallAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // Quran - نصوص القرآن (خط أكبر ووضوح أعلى)
  static TextStyle quranTextAr(BuildContext context) => GoogleFonts.amiriQuran(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 2.0,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: 0.5,
  );

  static TextStyle quranTextLargeAr(BuildContext context) =>
      GoogleFonts.amiriQuran(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 2.2,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.8,
      );

  // Adhkar - نصوص الأذكار
  static TextStyle adhkarTextAr(BuildContext context) => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.9,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // ==================== إنجليزي (Poppins) ====================

  static TextStyle headlineLargeEn(BuildContext context) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle headlineMediumEn(BuildContext context) =>
      GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLargeEn(BuildContext context) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMediumEn(BuildContext context) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmallEn(BuildContext context) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // ==================== فرنسي (Noto Sans) ====================

  static TextStyle headlineLargeFr(BuildContext context) =>
      GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineMediumFr(BuildContext context) =>
      GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLargeFr(BuildContext context) => GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyMediumFr(BuildContext context) => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmallFr(BuildContext context) => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // ==================== Button Styles ====================

  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onPrimary,
  );

  static TextStyle buttonMedium(BuildContext context) => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onPrimary,
  );

  static TextStyle buttonSmall(BuildContext context) => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onPrimary,
  );

  // ==================== Caption & Label ====================

  static TextStyle caption(BuildContext context) => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle label(BuildContext context) => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // ==================== Special Styles ====================

  // للعدادات والأرقام الكبيرة (التسبيح)
  static TextStyle counter(BuildContext context) => GoogleFonts.poppins(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
  );

  // لأوقات الصلاة
  static TextStyle prayerTime(BuildContext context) => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
    letterSpacing: 2,
  );

  static TextStyle prayerName(BuildContext context) => GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

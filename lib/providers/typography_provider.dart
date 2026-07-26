import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class TypographyProvider with ChangeNotifier {
  String _fontFamily = 'Cairo';
  double _baseFontSize = 1.0; // Scale factor: 0.8 to 1.4
  double _lineHeight = 1.5;

  TypographyProvider() {
    _loadSettings();
  }

  String get fontFamily => _fontFamily;
  double get valScale => _baseFontSize;
  double get lineHeight => _lineHeight;

  // Available fonts
  final List<String> availableFonts = [
    'Cairo',
    'Amiri',
    'Tajawal',
    'IBM Plex Sans Arabic',
    'Lateef',
  ];

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontFamily = prefs.getString('font_family') ?? 'Cairo';
    _baseFontSize = prefs.getDouble('font_scale') ?? 1.0;
    _lineHeight = prefs.getDouble('line_height') ?? 1.5;
    notifyListeners();
  }

  Future<void> setFontFamily(String font) async {
    if (availableFonts.contains(font)) {
      _fontFamily = font;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('font_family', font);
      notifyListeners();
    }
  }

  Future<void> setFontScale(double scale) async {
    if (scale >= 0.8 && scale <= 1.5) {
      _baseFontSize = scale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', scale);
      notifyListeners();
    }
  }

  Future<void> setLineHeight(double height) async {
    if (height >= 1.0 && height <= 2.5) {
      _lineHeight = height;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('line_height', height);
      notifyListeners();
    }
  }

  // Helper to get TextStyle with current settings
  TextStyle getTextStyle({
    required TextStyle baseStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    TextStyle style;
    switch (_fontFamily) {
      case 'Amiri':
        style = GoogleFonts.amiri(textStyle: baseStyle);
        break;
      case 'Tajawal':
        style = GoogleFonts.tajawal(textStyle: baseStyle);
        break;
      case 'IBM Plex Sans Arabic':
        style = GoogleFonts.ibmPlexSansArabic(textStyle: baseStyle);
        break;
      case 'Lateef':
        style = GoogleFonts.lateef(textStyle: baseStyle);
        break;
      case 'Cairo':
      default:
        style = GoogleFonts.cairo(textStyle: baseStyle);
        break;
    }

    return style.copyWith(
      color: color ?? baseStyle.color,
      fontSize: (fontSize ?? baseStyle.fontSize ?? 14.0) * _baseFontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      height: _lineHeight,
    );
  }

  TextTheme getTextTheme(TextTheme base) {
    return TextTheme(
      displayLarge: getTextStyle(baseStyle: base.displayLarge!),
      displayMedium: getTextStyle(baseStyle: base.displayMedium!),
      displaySmall: getTextStyle(baseStyle: base.displaySmall!),
      headlineLarge: getTextStyle(baseStyle: base.headlineLarge!),
      headlineMedium: getTextStyle(baseStyle: base.headlineMedium!),
      headlineSmall: getTextStyle(baseStyle: base.headlineSmall!),
      titleLarge: getTextStyle(baseStyle: base.titleLarge!),
      titleMedium: getTextStyle(baseStyle: base.titleMedium!),
      titleSmall: getTextStyle(baseStyle: base.titleSmall!),
      bodyLarge: getTextStyle(baseStyle: base.bodyLarge!),
      bodyMedium: getTextStyle(baseStyle: base.bodyMedium!),
      bodySmall: getTextStyle(baseStyle: base.bodySmall!),
      labelLarge: getTextStyle(baseStyle: base.labelLarge!),
      labelMedium: getTextStyle(baseStyle: base.labelMedium!),
      labelSmall: getTextStyle(baseStyle: base.labelSmall!),
    );
  }
}

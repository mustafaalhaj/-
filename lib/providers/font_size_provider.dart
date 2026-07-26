import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontSize = 1.0;
  String _fontFamily = 'Cairo';
  double _lineHeight = 1.5;

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  double get lineHeight => _lineHeight;

  FontSizeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('font_size') ?? 1.0;
    _fontFamily = prefs.getString('font_family') ?? 'Cairo';
    _lineHeight = prefs.getDouble('line_height') ?? 1.5;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_family', family);
  }

  Future<void> setLineHeight(double height) async {
    _lineHeight = height;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('line_height', height);
  }

  TextTheme getTextTheme(TextTheme base) {
    final TextTheme textTheme;
    switch (_fontFamily) {
      case 'Amiri':
        textTheme = GoogleFonts.amiriTextTheme(base);
        break;
      case 'Tajawal':
        textTheme = GoogleFonts.tajawalTextTheme(base);
        break;
      case 'IBM Plex Sans Arabic':
        textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(base);
        break;
      case 'Lateef':
        textTheme = GoogleFonts.lateefTextTheme(base);
        break;
      case 'Cairo':
      default:
        textTheme = GoogleFonts.cairoTextTheme(base);
        break;
    }

    // Apply line height
    return textTheme.apply(heightFactor: _lineHeight);
  }
}

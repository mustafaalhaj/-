import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// أنواع الثيمات المتاحة في التطبيق
/// أنواع الثيمات المتاحة في التطبيق
enum AppThemeType { light, dark, fajr, kaaba, custom }

/// Provider لإدارة الثيم الحالي وحفظه
class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.dark; // Default to Dark
  static const String _themeKey = 'app_theme';

  // Cache للثيمات لتحسين الأداء
  final Map<AppThemeType, ThemeData> _themeCache = {};

  AppThemeType get currentTheme => _currentTheme;

  // Custom Colors
  Color _customPrimary = const Color(0xFF009688);
  Color _customSecondary = const Color(0xFFFFAB00);
  Color _customBackground = const Color(0xFFF5F5F5);

  Color get customPrimary => _customPrimary;
  Color get customSecondary => _customSecondary;
  Color get customBackground => _customBackground;

  // Gradient Settings
  bool _enableGradients = true;
  String _selectedGradient = 'sunset'; // sunset, fajr, night, gold, royal

  bool get enableGradients => _enableGradients;
  String get selectedGradient => _selectedGradient;

  ThemeProvider() {
    _initializeThemeCache();
    _loadTheme();
  }

  /// تهيئة cache الثيمات
  void _initializeThemeCache() {
    _themeCache[AppThemeType.light] = _buildLightTheme();
    _themeCache[AppThemeType.dark] = _buildDarkTheme();
    _themeCache[AppThemeType.fajr] = _buildFajrTheme();
    _themeCache[AppThemeType.kaaba] = _buildKaabaTheme();
    // Custom theme will be built dynamically
  }

  /// تحميل الثيم المحفوظ والألوان المخصصة
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Colors
    _customPrimary = Color(prefs.getInt('custom_primary') ?? 0xFF009688);
    _customSecondary = Color(prefs.getInt('custom_secondary') ?? 0xFFFFAB00);
    _customBackground = Color(prefs.getInt('custom_background') ?? 0xFFF5F5F5);

    // Load Gradients
    _enableGradients = prefs.getBool('enable_gradients') ?? true;
    _selectedGradient = prefs.getString('selected_gradient') ?? 'sunset';

    final themeName = prefs.getString(_themeKey);

    if (themeName != null) {
      try {
        _currentTheme = AppThemeType.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => AppThemeType.light,
        );

        // Rebuild cache if custom
        if (_currentTheme == AppThemeType.custom) {
          _themeCache[AppThemeType.custom] = _buildCustomTheme();
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error loading theme: $e');
      }
    }
  }

  /// تغيير الثيم وحفظه
  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme == theme && theme != AppThemeType.custom) return;

    _currentTheme = theme;
    if (theme == AppThemeType.custom) {
      _themeCache[AppThemeType.custom] = _buildCustomTheme();
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }

  /// تحديث الألوان المخصصة
  Future<void> updateCustomColors({
    Color? primary,
    Color? secondary,
    Color? background,
  }) async {
    if (primary != null) _customPrimary = primary;
    if (secondary != null) _customSecondary = secondary;
    if (background != null) _customBackground = background;

    // Refresh custom theme
    _themeCache[AppThemeType.custom] = _buildCustomTheme();

    // If currently custom, notify listeners to apply changes immediately
    if (_currentTheme == AppThemeType.custom) {
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('custom_primary', _customPrimary.toARGB32());
    await prefs.setInt('custom_secondary', _customSecondary.toARGB32());
    await prefs.setInt('custom_background', _customBackground.toARGB32());
  }

  Future<void> toggleGradients(bool value) async {
    _enableGradients = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_gradients', value);
  }

  Future<void> setGradientPreset(String preset) async {
    _selectedGradient = preset;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_gradient', preset);
  }

  /// الحصول على بيانات الثيم الحالي من الـ cache
  ThemeData getThemeData() {
    if (_currentTheme == AppThemeType.custom) {
      return _themeCache[AppThemeType.custom] ?? _buildCustomTheme();
    }
    return _themeCache[_currentTheme] ?? _buildLightTheme();
  }

  /// بناء الثيم المخصص
  ThemeData _buildCustomTheme() {
    // Determine brightness based on background luminance
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(_customBackground) ==
        Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkBg ? Brightness.dark : Brightness.light,
      colorScheme: isDarkBg
          ? ColorScheme.dark(
              primary: _customPrimary,
              secondary: _customSecondary,
              surface: _customBackground,
              error: const Color(0xFFCF6679),
            )
          : ColorScheme.light(
              primary: _customPrimary,
              secondary: _customSecondary,
              surface: _customBackground,
              error: const Color(0xFFB00020),
            ),
      scaffoldBackgroundColor: _customBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: _customBackground,
        foregroundColor: isDarkBg ? Colors.white : Colors.black,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// بناء الثيم الفاتح
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF009688),
        primaryContainer: Color(0xFFB2DFDB),
        secondary: Color(0xFFFFAB00),
        secondaryContainer: Color(0xFFFFECB3),
        surface: Color(0xFFFAFAFA),
        error: Color(0xFFE53935),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// بناء الثيم الداكن
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4DB6AC),
        primaryContainer: Color(0xFF00695C),
        secondary: Color(0xFFFFD54F),
        secondaryContainer: Color(0xFFFF8F00),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFE53935),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// بناء ثيم الفجر (أزرق وزهري)
  ThemeData _buildFajrTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2), // أزرق داكن
        primaryContainer: Color(0xFFBBDEFB), // أزرق فاتح
        secondary: Color(0xFFEC407A), // زهري
        secondaryContainer: Color(0xFFF8BBD0), // زهري فاتح
        surface: Color(0xFFF3F9FF), // أزرق ثلجي فاتح جداً
        error: Color(0xFFE53935),
        tertiary: Color(0xFF64B5F6), // أزرق سماوي
      ),
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// بناء ثيم الكعبة (أسود وذهبي)
  ThemeData _buildKaabaTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFD700), // ذهبي
        primaryContainer: Color(0xFF9C7A2F), // ذهبي داكن
        secondary: Color(0xFFC5A572), // بيج ذهبي
        secondaryContainer: Color(0xFF8B7355), // بني فاتح
        surface: Color(0xFF1C1C1C), // أسود فاتح
        error: Color(0xFFE53935),
        tertiary: Color(0xFFFFE082), // ذهبي فاتح
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// هل الثيم الحالي داكن؟
  bool get isDark =>
      _currentTheme == AppThemeType.dark ||
      _currentTheme == AppThemeType.kaaba ||
      (_currentTheme == AppThemeType.custom &&
          ThemeData.estimateBrightnessForColor(_customBackground) ==
              Brightness.dark);
}

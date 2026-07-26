import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/notification_service.dart';
import 'services/firebase_notification_service.dart'; // Added
import 'features/hijri_calendar/data/hijri_notification_service.dart';
import 'package:firebase_core/firebase_core.dart'; // REQUIRED
import 'services/update_service.dart';
import 'utils/performance_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // import

import 'screens/quran_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/adhkar_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/asmaul_husna_screen.dart';
import 'screens/duas_screen.dart';
import 'screens/more_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/home_screen.dart'; // Added HomeScreen
import 'screens/home_layout_editor_screen.dart';
import 'screens/typography_settings_screen.dart';
import 'screens/fasting_tracker_screen.dart';
import 'screens/notifications_screen.dart'; // Added
import 'features/hijri_calendar/presentation/hijri_calendar_screen.dart';
import 'screens/update_screen.dart'; // Update Screen
import 'screens/about_screen.dart'; // About Screen
import 'screens/privacy_policy_screen.dart'; // Added
import 'widgets/glass_bottom_nav.dart'; // Import Glass Footer

import 'package:provider/provider.dart';
import 'providers/typography_provider.dart';
import 'providers/prayer_times_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/home_layout_provider.dart';
import 'providers/notification_preferences_provider.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/admin_notification_screen.dart';

// Background Handler MUST be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("Handling a background message: ${message.messageId}");
  } catch (e) {
    debugPrint("Error handling background message: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحسينات الأداء
  PerformanceConfig.enableHighPerformance();

  // تثبيت اتجاه الشاشة للهواتف فقط
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  await _initializeServices();

  // Register Background Handler for mobile only
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('FCM background handler skipped: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TypographyProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HomeLayoutProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationPreferencesProvider(),
        ),
      ],
      child: const AnaMuslimApp(),
    ),
  );
}

// Initialize services asynchronously without blocking the app
Future<void> _initializeServices() async {
  try {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await Firebase.initializeApp();
        await FirebaseNotificationService().initialize();
      } catch (e) {
        debugPrint('Firebase init warning: $e');
      }
    }
    await NotificationService().init();
    await HijriNotificationService().initialize();
  } catch (e) {
    debugPrint('Error initializing Services: $e');
  }
}

class AnaMuslimApp extends StatelessWidget {
  const AnaMuslimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TypographyProvider, ThemeProvider>(
      builder: (context, typographyProvider, themeProvider, child) {
        return MaterialApp(
          title: 'Ana Muslim',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark, // Force Dark Mode Globally
          theme: themeProvider.getThemeData().copyWith(
            textTheme: typographyProvider.getTextTheme(
              themeProvider.getThemeData().textTheme,
            ),
          ),
          darkTheme: themeProvider.getThemeData().copyWith(
            textTheme: typographyProvider.getTextTheme(
              themeProvider.getThemeData().textTheme,
            ),
          ),

          // تحسينات الأداء
          showPerformanceOverlay: false,
          checkerboardRasterCacheImages: false,
          checkerboardOffscreenLayers: false,

          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            // Apply font scale factor
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(typographyProvider.valScale),
              ),
              child: child!,
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar')],
          locale: const Locale('ar'),
          initialRoute: '/',
          routes: {
            '/': (context) => const MainScreen(),
            '/home': (context) => const MainScreen(),
            '/quran': (context) => const QuranScreen(),
            '/prayer': (context) => const PrayerTimesScreen(),
            '/adhkar': (context) => const AdhkarScreen(),
            '/hadith': (context) => const HadithScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/qibla': (context) => const QiblaScreen(),
            '/tasbih': (context) => const TasbihScreen(),
            '/asmaul-husna': (context) => const AsmaulHusnaScreen(),
            '/duas': (context) => const DuasScreen(),
            '/ai-chat': (context) => const AIChatScreen(),
            '/mood': (context) => const MoodSelectionScreen(),
            '/home-layout-editor': (context) => const HomeLayoutEditorScreen(),
            '/typography-settings': (context) =>
                const TypographySettingsScreen(),
            '/live': (context) => const LiveStreamScreen(),
            '/fasting': (context) => const FastingTrackerScreen(),
            '/notifications': (context) => const NotificationsScreen(), // Added
            '/notification-settings': (context) =>
                const NotificationSettingsScreen(),
            '/admin-notifications': (context) =>
                const AdminNotificationScreen(),
            '/hijri-calendar': (context) => const HijriCalendarScreen(),
            '/about': (context) => const AboutScreen(),
            '/privacy-policy': (context) =>
                const PrivacyPolicyScreen(), // Added // About Screen
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start at Home (center)

  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await UpdateService.checkUpdate();
    if (updateInfo != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateScreen(
            latestVersion: updateInfo['latest_version'],
            currentVersion: updateInfo['current_version'],
            downloadUrl: updateInfo['download_url'],
            isForceUpdate: updateInfo['force_update'],
          ),
        ),
      );
    }
  }

  // Order matches GlassBottomNav items:
  // 0: Quran, 1: Prayer, 2: Home, 3: Adhkar, 4: More
  final List<Widget> _screens = [
    const QuranScreen(),
    const PrayerTimesScreen(),
    const HomeScreen(), // Main Dashboard with Glass Grid
    const AdhkarScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1537), // ✅ طبقة أمان داكنة تمنع الرمادي على iOS
      extendBody: true, // IMPORTANT: Allows body to go behind bottom nav
      body: Stack(
        children: [
          // 1. Main Content with IndexedStack for instant tab navigation
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // 2. Floating Glass Bottom Nav with RepaintBoundary
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: GlassBottomNav(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      // No standard bottomNavigationBar
    );
  }
}

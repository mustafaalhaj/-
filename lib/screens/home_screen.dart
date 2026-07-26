import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../services/firebase_notification_service.dart';
import '../providers/prayer_times_provider.dart';
import 'package:adhan/adhan.dart';
import '../providers/home_layout_provider.dart';

/// الشاشة الرئيسية - تستخدم ListView مباشرةً لضمان العرض الصحيح على iOS
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = intl.DateFormat('HH:mm').format(DateTime.now());
      });
      Future.delayed(const Duration(minutes: 1), _updateTime);
    }
  }

  String _getTimeRemaining(DateTime prayerTime) {
    final now = DateTime.now();
    final difference = prayerTime.difference(now);
    if (difference.isNegative) return 'الآن';
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (hours > 0) {
      return 'باقي $hours ساعة و $minutes دقيقة';
    } else {
      return 'باقي $minutes دقيقة';
    }
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final layoutProvider = Provider.of<HomeLayoutProvider>(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        isDark: isDark,
        // ✅ استخدام ListView مباشرةً بدل CustomScrollView+Slivers
        // ListView مضمون العمل على iOS/Android بدون مشاكل القيود
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            children: _buildSections(layoutProvider, primaryColor),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(
    HomeLayoutProvider layoutProvider,
    Color primaryColor,
  ) {
    // ✅ لا نعتمد على isLoading - نعرض الافتراضي فوراً دائماً
    final activeItems = layoutProvider.activeWidgets;

    List<Widget> sections = [];

    if (activeItems.isEmpty) {
      sections.add(_buildHeader(primaryColor));
      sections.add(_buildNextPrayer());
      sections.add(_buildQuickActions(primaryColor));
      sections.add(_buildHijriDate());
      sections.add(_buildDailyVerse());
    } else {
      for (var item in activeItems) {
        switch (item.type) {
          case HomeWidgetType.header:
            sections.add(_buildHeader(primaryColor));
            break;
          case HomeWidgetType.nextPrayer:
            sections.add(_buildNextPrayer());
            break;
          case HomeWidgetType.quickActions:
            sections.add(_buildQuickActions(primaryColor));
            break;
          case HomeWidgetType.dailyVerse:
            sections.add(_buildDailyVerse());
            break;
          case HomeWidgetType.hijriDate:
            sections.add(_buildHijriDate());
            break;
        }
      }
    }

    return sections;
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السلام عليكم',
                style: GoogleFonts.cairo(fontSize: 18, color: Colors.white),
              ),
              ValueListenableBuilder<int>(
                valueListenable: FirebaseNotificationService().unreadCount,
                builder: (context, count, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentTime,
            style: GoogleFonts.inter(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Next Prayer ────────────────────────────────────────────────────────────

  Widget _buildNextPrayer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Consumer<PrayerTimesProvider>(
        builder: (context, prayerProvider, child) {
          if (prayerProvider.isLoading) {
            return GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري تحميل المواقيت...',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (prayerProvider.prayerTimes == null) {
            return GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'تعذر تحميل المواقيت',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }

          final nextPrayer = prayerProvider.prayerTimes!.nextPrayer();
          final nextPrayerTime = prayerProvider.prayerTimes!.timeForPrayer(nextPrayer);
          final nextPrayerName = _getPrayerName(nextPrayer);
          final nextPrayerTimeStr = nextPrayerTime != null
              ? intl.DateFormat.jm('ar').format(nextPrayerTime)
              : '--:--';
          final timeRemaining = nextPrayerTime != null
              ? _getTimeRemaining(nextPrayerTime)
              : '';

          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصلاة القادمة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nextPrayerName,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nextPrayerTimeStr,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      if (timeRemaining.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeRemaining,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Quick Actions Grid ─────────────────────────────────────────────────────

  Widget _buildQuickActions(Color primaryColor) {
    final features = [
      {'title': 'مواقيت الصلاة', 'icon': Icons.access_time_filled_rounded, 'route': '/prayer'},
      {'title': 'القرآن الكريم', 'icon': Icons.menu_book_rounded, 'route': '/quran'},
      {'title': 'الأذكار', 'icon': Icons.volunteer_activism_rounded, 'route': '/adhkar'},
      {'title': 'القبلة', 'icon': Icons.explore_rounded, 'route': '/qibla'},
      {'title': 'الحديث', 'icon': Icons.format_quote_rounded, 'route': '/hadith'},
      {'title': 'التسبيح', 'icon': Icons.fingerprint_rounded, 'route': '/tasbih'},
      {'title': 'تتبع الصيام', 'icon': Icons.nights_stay_rounded, 'route': '/fasting'},
      {'title': 'التقويم الهجري', 'icon': Icons.calendar_month_rounded, 'route': '/hijri-calendar'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true, // ✅ مهم جداً داخل ListView
        physics: const NeverScrollableScrollPhysics(), // ✅ يتحكم ListView في التمرير
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return GlassCard(
            onTap: () {
              Navigator.pushNamed(context, feature['route'] as String);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  feature['title'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Daily Verse ────────────────────────────────────────────────────────────

  Widget _buildDailyVerse() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'آية اليوم',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hijri Date ─────────────────────────────────────────────────────────────

  Widget _buildHijriDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              '14 رجب 1445',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

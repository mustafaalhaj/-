import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:async';
import '../providers/prayer_times_provider.dart';
import 'advanced_prayer_settings_screen.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import '../utils/app_colors.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  String _hijriDate = '';
  Prayer? _nextPrayer;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _updateHijriDate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimesProvider>().fetchPrayerTimes();
    });

    _startTimer();
  }

  void _updateHijriDate() {
    final today = HijriCalendar.now();
    setState(() {
      _hijriDate = today.toFormat('dd MMMM yyyy');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final provider = context.read<PrayerTimesProvider>();
      final prayerTimes = provider.prayerTimes;

      if (prayerTimes != null) {
        final now = DateTime.now();
        final next = prayerTimes.nextPrayer();

        if (next != Prayer.none) {
          final nextTime = prayerTimes.timeForPrayer(next);
          if (nextTime != null) {
            setState(() {
              _nextPrayer = next;
              _timeRemaining = nextTime.difference(now);
            });
          }
        } else {
          setState(() {
            _nextPrayer = Prayer.fajr;
            _timeRemaining = Duration.zero;
          });
        }
      }
    });
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'مواقيت الصلاة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedPrayerSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GlassBackground(
        isDark: isDark,
        child: Consumer<PrayerTimesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.fetchPrayerTimes,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final prayerTimes = provider.prayerTimes;

            // Format time remaining
            final hours = _timeRemaining.inHours;
            final minutes = _timeRemaining.inMinutes % 60;
            final seconds = _timeRemaining.inSeconds % 60;
            final timeString = hours > 0
                ? '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

            return SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            _hijriDate,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _nextPrayer != null
                                ? 'متبقي على ${_getPrayerName(_nextPrayer!)}'
                                : 'الصلاة القادمة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            timeString,
                            style: GoogleFonts.inter(
                              fontSize: 60,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                provider.locationName,
                                style: GoogleFonts.cairo(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prayer List
                  if (prayerTimes != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildPrayerRow(
                            'الفجر',
                            prayerTimes.fajr,
                            Icons.wb_twilight_rounded,
                          ),
                          _buildPrayerRow(
                            'الشروق',
                            prayerTimes.sunrise,
                            Icons.wb_sunny_rounded,
                            isPrayer: false,
                          ),
                          _buildPrayerRow(
                            'الظهر',
                            prayerTimes.dhuhr,
                            Icons.wb_sunny_rounded,
                          ),
                          _buildPrayerRow(
                            'العصر',
                            prayerTimes.asr,
                            Icons.wb_cloudy_rounded,
                          ),
                          _buildPrayerRow(
                            'المغرب',
                            prayerTimes.maghrib,
                            Icons.nights_stay_rounded,
                          ),
                          _buildPrayerRow(
                            'العشاء',
                            prayerTimes.isha,
                            Icons.bedtime_rounded,
                          ),
                          const SizedBox(height: 100), // Space for bottom nav
                        ]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerRow(
    String name,
    DateTime time,
    IconData icon, {
    bool isPrayer = true,
  }) {
    final formattedTime = DateFormat.jm('ar').format(time);
    final isNext = _nextPrayer != null && _getPrayerName(_nextPrayer!) == name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: isNext ? AppColors.secondary : Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                color: isNext ? AppColors.secondary : Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: isNext
                  ? BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
              child: Text(
                formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  color: isNext ? AppColors.secondary : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

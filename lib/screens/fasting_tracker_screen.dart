import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_background.dart';
import '../providers/prayer_times_provider.dart';
import 'dart:async';

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});

  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen> {
  late HijriCalendar _hijriNow;
  bool _isFasting = false;
  Timer? _timer;
  String _countDown = '';

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkIfFastingDay();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkIfFastingDay() {
    final weekday = DateTime.now().weekday;
    // Mon=1 ... Sun=7. In Dart DateTime, Mon=1, Thu=4.
    final isMonOrThu =
        (weekday == DateTime.monday || weekday == DateTime.thursday);
    final isWhiteDay = [13, 14, 15].contains(_hijriNow.hDay);

    if (isMonOrThu || isWhiteDay) {
      if (mounted) setState(() => _isFasting = true);
    }
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final provider = Provider.of<PrayerTimesProvider>(context, listen: false);
    if (provider.prayerTimes == null) return;

    final maghrib = provider.prayerTimes!.maghrib;
    final now = DateTime.now();

    if (now.isBefore(maghrib)) {
      final diff = maghrib.difference(now);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

      if (mounted) {
        setState(() {
          _countDown = "$hours:$minutes:$seconds";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _countDown = "00:00:00";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, colorScheme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFastingStatusCard(colorScheme),
                    const SizedBox(height: 20),
                    _buildUpcomingFastingDays(colorScheme),
                    const SizedBox(height: 20),
                    _buildDuaCard(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "تتبع الصيام",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -30,
                bottom: -30,
                child: Icon(
                  Icons.nights_stay,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      _hijriNow.toFormat("dd MMMM yyyy"),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE d MMMM', 'ar').format(DateTime.now()),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFastingStatusCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "هل أنت صائم اليوم؟",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _isFasting,
                onChanged: (val) => setState(() => _isFasting = val),
                activeThumbColor: colorScheme.primary,
              ),
            ],
          ),
          if (_isFasting) ...[
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "المتبقي للإفطار",
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              _countDown,
              style: GoogleFonts.orbitron(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 5),
            Consumer<PrayerTimesProvider>(
              builder: (ctx, prov, _) {
                if (prov.prayerTimes == null) return const SizedBox();
                return Text(
                  "المغرب: ${DateFormat.jm('ar').format(prov.prayerTimes!.maghrib)}",
                  style: GoogleFonts.cairo(fontSize: 12),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingFastingDays(ColorScheme colorScheme) {
    // Determine upcoming recommend days
    // Logic: Find next Mon/Thu and next White Days.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الأيام المستحبة القادمة",
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildDayTile("الخميس القادم", "سنة مؤكدة", Icons.event, colorScheme),
        _buildDayTile(
          "١٣ جمادى الأول",
          "الأيام البيض",
          Icons.brightness_6,
          colorScheme,
        ),
        _buildDayTile("الإثنين القادم", "سنة مؤكدة", Icons.event, colorScheme),
      ],
    );
  }

  Widget _buildDayTile(
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.cairo(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildDuaCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Light Gold for Dua
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.amber[800]),
              const SizedBox(width: 10),
              Text(
                "دعاء الإفطار",
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "ذهَبَ الظَّمأُ، وابتلَّت العروقُ، وثَبَتَ الأجرُ إن شاءَ اللهُ",
            style: GoogleFonts.amiri(fontSize: 20, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

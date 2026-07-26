// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/hijri_repository.dart';
import '../domain/models/hijri_date.dart';
import '../domain/models/hijri_day.dart';
import '../domain/models/hijri_event.dart'; // Ensure EventType is imported if needed

import '../presentation/hijri_day_tile.dart';
import '../../../widgets/islamic_loader.dart'; // Added

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriDate _currentMonth;
  final HijriRepository _repository = HijriRepository();
  bool _isLoading = true;
  List<HijriDay> _days = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = HijriDate.now();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      debugPrint('HijriCalendar: Initializing repository...');
      await _repository.initialize();
      _updateDays();
      debugPrint(
        'HijriCalendar: Data initialized. Days count: ${_days.length}',
      );
    } catch (e, stack) {
      debugPrint('HijriCalendar Error: $e');
      debugPrint(stack.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحميل التقويم: $e')),
        );
      }
    }
  }

  void _updateDays() {
    if (!mounted) return;
    try {
      final days = _repository.getMonthDays(
        _currentMonth.hMonth,
        _currentMonth.hYear,
      );
      setState(() {
        _days = days;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error updating days: $e');
    }
  }

  void _prevMonth() {
    setState(() {
      int newMonth = _currentMonth.hMonth - 1;
      int newYear = _currentMonth.hYear;
      if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }
      _currentMonth = HijriDate.fromHijri(newYear, newMonth, 1);
      _updateDays();
    });
  }

  void _nextMonth() {
    setState(() {
      int newMonth = _currentMonth.hMonth + 1;
      int newYear = _currentMonth.hYear;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      }
      _currentMonth = HijriDate.fromHijri(newYear, newMonth, 1);
      _updateDays();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'التقويم الهجري',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white),
            onPressed: () {
              setState(() {
                _currentMonth = HijriDate.now();
                _updateDays();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF009688), const Color(0xFF00695C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildWeekDays(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: IslamicLoader(color: Colors.white, size: 60),
                      )
                    : _days.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white70,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد بيانات متاحة',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _initializeData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.teal,
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            _prevMonth(); // Swipe Right (RTL: Previous) -> No, standard swipe logic
                            // Swipe Right usually means go to previous in LTR.
                            // In RTL context? Let's check logic implies previous.
                          } else if (details.primaryVelocity! < 0) {
                            _nextMonth();
                          }
                        },
                        child: _buildCalendarGrid(),
                      ),
              ),
              _buildFooterLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed:
                  _nextMonth, // RTL: Next is Left Arrow? Depends on locale.
              // Let's stick to standard arrows:
              // Right Arrow -> Next Month
              // Left Arrow -> Prev Month
              // But in Arabic UI, Left Arrow is visually "Forward/Next" usually?
              // No, usually Right is Back, Left is Forward in RTL?
              // Let's use Icons.chevron_left for Next (Forward in RTL) and Right for Prev.
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            Column(
              children: [
                Text(
                  _currentMonth.monthName,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                Text(
                  '${_currentMonth.hYear} هـ',
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            IconButton(
              onPressed: _prevMonth,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    // Standard Hijri week usually starts on Sunday or Saturday?
    // HijriRepository.getMonthDays generates days aligned to a week start.
    // The previous implementation of getMonthDays aligned to Sunday?
    // Let's check HijriRepository logic from previous step.
    // "final offset = firstWeekday == 7 ? 0 : firstWeekday;"
    // If firstWeekday is Sun (7) -> Offset 0. So Week starts Sunday.
    // If firstWeekday is Mon (1) -> Offset 1. So Row is [Sun, Mon...]
    // So the headers MUST be [Sun, Mon, Tue, Wed, Thu, Fri, Sat]

    final days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map(
              (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // physics: const NeverScrollableScrollPhysics(), // Allow scrolling if needed, but PageView is better.
      // Keeping simple for now
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final day = _days[index];
        if (!day.isCurrentMonth) {
          // Optionally show empty or dimmed
          return Opacity(opacity: 0.3, child: HijriDayTile(day: day));
        }
        return HijriDayTile(day: day, onTap: () => _showDayDetails(day));
      },
    );
  }

  void _showDayDetails(HijriDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DayDetailsSheet(day: day),
    );
  }

  Widget _buildFooterLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Colors.green, 'صيام'),
          const SizedBox(width: 16),
          _buildLegendItem(const Color(0xFFFFD700), 'أيام بيض'),
          const SizedBox(width: 16),
          _buildLegendItem(const Color(0xFF9C27B0), 'مناسبة'), // Purple
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _DayDetailsSheet extends StatelessWidget {
  final HijriDay day;

  const _DayDetailsSheet({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gregorianDate = day.date.toGregorian();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${day.day} ${day.date.monthName} ${day.date.hYear}',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${day.date.weekdayName}، ${gregorianDate.day}-${gregorianDate.month}-${gregorianDate.year} م',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          if (day.event != null) ...[
            const Divider(height: 32),
            _buildEventInfo(day.event!, isDark),
          ],
          if (day.isRecommendedFasting) ...[
            const Divider(height: 32),
            _buildFastingInfo(day, isDark),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEventInfo(HijriEvent event, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star, color: Color(0xFF9C27B0)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مناسبة إسلامية',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              Text(
                event.title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFastingInfo(HijriDay day, bool isDark) {
    String title = 'صيام مستحب';
    String desc = '';

    if (day.isWhiteDay) {
      title = 'الأيام البيض';
      desc = 'صيام أيام 13، 14، 15 من كل شهر هجري.';
    } else if (day.isMonday) {
      title = 'صيام الإثنين';
      desc = 'سنة عن النبي ﷺ.';
    } else if (day.isThursday) {
      title = 'صيام الخميس';
      desc = 'سنة عن النبي ﷺ.';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.restaurant, color: Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

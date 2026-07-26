import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../data/adhkar_data.dart';
import '../widgets/glass_background.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final List<Map<String, dynamic>> _adhkarCategories = AdhkarData.categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: CustomScrollView(
          slivers: [
            // Beautiful App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'الأذكار',
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),

            // Categories Grid
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = _adhkarCategories[index];
                  return _buildCategoryCard(context, category);
                }, childCount: _adhkarCategories.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdhkarDetailScreen(
                  title: category['title'],
                  items: category['items'],
                  color: category['color'],
                  gradient: category['gradient'],
                  time: category['time'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category['title'] as String,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category['time'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(category['items'] as List).length} ذكر',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdhkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color color;
  final List<Color> gradient;
  final String time;

  const AdhkarDetailScreen({
    super.key,
    required this.title,
    required this.items,
    required this.color,
    required this.gradient,
    required this.time,
  });

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late List<int> _counts;
  int _totalCompleted = 0;

  @override
  void initState() {
    super.initState();
    _counts = List.filled(widget.items.length, 0);
  }

  void _incrementCount(int index) async {
    final targetCount = widget.items[index]['count'] as int;
    if (_counts[index] < targetCount) {
      // Vibrate on tap
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      }

      setState(() {
        _counts[index]++;
        if (_counts[index] == targetCount) {
          _totalCompleted++;
        }
      });
    }
  }

  void _resetCount(int index) {
    setState(() {
      if (_counts[index] == widget.items[index]['count']) {
        _totalCompleted--;
      }
      _counts[index] = 0;
    });
  }

  void _resetAll() {
    setState(() {
      _counts = List.filled(widget.items.length, 0);
      _totalCompleted = 0;
    });
  }

  void _shareAdhkar() {
    final text =
        '''
${widget.title}

${widget.items.map((item) => '• ${item['text']} (${item['count']} مرة)').join('\n\n')}

---
تطبيق أنا مسلم 🕌
''';
    Share.share(text, subject: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalCompleted / widget.items.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Progress
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: widget.gradient,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_totalCompleted / ${widget.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerRight,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('إعادة تعيين'),
                      content: const Text('هل تريد إعادة تعيين جميع العدادات؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _resetAll();
                            Navigator.pop(context);
                          },
                          child: const Text('إعادة تعيين'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareAdhkar,
              ),
            ],
          ),

          // Adhkar List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = widget.items[index];
                final targetCount = item['count'] as int;
                final currentCount = _counts[index];
                final isCompleted = currentCount >= targetCount;
                final itemProgress = currentCount / targetCount;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [
                              Colors.green.withValues(alpha: 0.1),
                              Colors.green.withValues(alpha: 0.05),
                            ],
                          )
                        : null,
                    color: isCompleted ? null : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isCompleted
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _incrementCount(index),
                      onLongPress: () => _resetCount(index),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Dhikr Text
                            Text(
                              item['text'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                height: 2,
                                color: isCompleted
                                    ? Colors.green.shade700
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),

                            // Benefit
                            if (item['benefit'] != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: widget.color,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['benefit'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Counter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: itemProgress,
                                        backgroundColor: Colors.grey[200],
                                        color: isCompleted
                                            ? Colors.green
                                            : widget.color,
                                        strokeWidth: 6,
                                      ),
                                      if (isCompleted)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 28,
                                        )
                                      else
                                        Text(
                                          '$currentCount',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: widget.color,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$currentCount / $targetCount',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted
                                            ? Colors.green
                                            : widget.color,
                                      ),
                                    ),
                                    Text(
                                      isCompleted ? 'مكتمل ✓' : 'اضغط للعد',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: widget.items.length),
            ),
          ),
        ],
      ),
    );
  }
}

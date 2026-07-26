import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../widgets/glass_background.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _totalCount = 0;
  int _targetCount = 33;
  int _selectedTasbihIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _tasbihList = [
    {
      'text': 'سُبْحَانَ اللَّهِ',
      'translation': 'Glory be to Allah',
      'color': Colors.teal,
    },
    {
      'text': 'الْحَمْدُ لِلَّهِ',
      'translation': 'Praise be to Allah',
      'color': Colors.green,
    },
    {
      'text': 'اللَّهُ أَكْبَرُ',
      'translation': 'Allah is the Greatest',
      'color': Colors.indigo,
    },
    {
      'text': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'translation': 'There is no god but Allah',
      'color': Colors.purple,
    },
    {
      'text': 'أَسْتَغْفِرُ اللَّهَ',
      'translation': 'I seek forgiveness from Allah',
      'color': Colors.orange,
    },
    {
      'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation': 'There is no power except with Allah',
      'color': Colors.blue,
    },
  ];

  final List<int> _targets = [33, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalCount = prefs.getInt('tasbih_total') ?? 0;
      _targetCount = prefs.getInt('tasbih_target') ?? 33;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_total', _totalCount);
    await prefs.setInt('tasbih_target', _targetCount);
  }

  Future<void> _increment() async {
    // Vibrate
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 30);
    }

    // Animate
    await _animationController.forward();
    await _animationController.reverse();

    setState(() {
      _count++;
      _totalCount++;
    });

    // Check if target reached
    if (_count >= _targetCount) {
      HapticFeedback.heavyImpact();
      _showCompletionDialog();
    }

    _saveData();
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _resetTotal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإجمالي'),
        content: const Text('هل تريد إعادة تعيين العداد الإجمالي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _totalCount = 0;
                _count = 0;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              'ما شاء الله!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'أكملت $_targetCount تسبيحة\nجزاك الله خيراً',
          style: GoogleFonts.cairo(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('البدء من جديد'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentTasbih = _tasbihList[_selectedTasbihIndex];
    final progress = _count / _targetCount;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'التسبيح',
                  style: GoogleFonts.cairo(
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
                      colors: [
                        (currentTasbih['color'] as Color),
                        (currentTasbih['color'] as Color).withValues(
                          alpha: 0.7,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'إعادة تعيين',
                  onPressed: _reset,
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.flag),
                  tooltip: 'الهدف',
                  onSelected: (value) {
                    setState(() {
                      _targetCount = value;
                    });
                    _saveData();
                  },
                  itemBuilder: (context) => _targets
                      .map(
                        (t) =>
                            PopupMenuItem(value: t, child: Text('$t تسبيحة')),
                      )
                      .toList(),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Total Count Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            label: 'الهدف',
                            value: '$_targetCount',
                            icon: Icons.flag,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          _buildStatItem(
                            label: 'الإجمالي',
                            value: '$_totalCount',
                            icon: Icons.all_inclusive,
                            onTap: _resetTotal,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tasbih Selector
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tasbihList.length,
                        itemBuilder: (context, index) {
                          final tasbih = _tasbihList[index];
                          final isSelected = index == _selectedTasbihIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTasbihIndex = index;
                                _count = 0;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (tasbih['color'] as Color)
                                    : (tasbih['color'] as Color).withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: tasbih['color'] as Color,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  tasbih['text'],
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : tasbih['color'] as Color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tasbih Text
                    Text(
                      currentTasbih['text'],
                      style: GoogleFonts.amiri(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: currentTasbih['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTasbih['translation'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Counter Button
                    GestureDetector(
                      onTap: _increment,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (currentTasbih['color'] as Color),
                                (currentTasbih['color'] as Color).withValues(
                                  alpha: 0.7,
                                ),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (currentTasbih['color'] as Color)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress Ring
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: CircularProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                              // Count
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_count',
                                    style: GoogleFonts.cairo(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'اضغط للتسبيح',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

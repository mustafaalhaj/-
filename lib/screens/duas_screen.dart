import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/glass_background.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  String _selectedCategory = 'الكل';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'الكل', 'icon': Icons.apps},
    {'name': 'الصباح والمساء', 'icon': Icons.wb_sunny},
    {'name': 'الصلاة', 'icon': Icons.mosque},
    {'name': 'النوم', 'icon': Icons.bedtime},
    {'name': 'الطعام', 'icon': Icons.restaurant},
    {'name': 'السفر', 'icon': Icons.flight},
    {'name': 'الاستغفار', 'icon': Icons.favorite},
  ];

  final List<Map<String, dynamic>> _duas = [
    {
      'title': 'دعاء الاستفتاح',
      'arabic':
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ',
      'meaning': 'سبحانك اللهم: أنزهك عن كل نقص، وبحمدك: متلبساً بحمدك',
      'category': 'الصلاة',
      'source': 'رواه أبو داود والترمذي',
    },
    {
      'title': 'دعاء الصباح',
      'arabic':
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'meaning': 'الإقرار بتوحيد الله في ملكه والحمد له',
      'category': 'الصباح والمساء',
      'source': 'رواه مسلم',
    },
    {
      'title': 'دعاء المساء',
      'arabic':
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'meaning': 'الإقرار بتوحيد الله في ملكه والحمد له',
      'category': 'الصباح والمساء',
      'source': 'رواه مسلم',
    },
    {
      'title': 'سيد الاستغفار',
      'arabic':
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      'meaning': 'أعظم صيغ الاستغفار',
      'category': 'الاستغفار',
      'source': 'رواه البخاري',
    },
    {
      'title': 'دعاء النوم',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'meaning': 'النوم أخو الموت والاستيقاظ كالحياة',
      'category': 'النوم',
      'source': 'رواه البخاري',
    },
    {
      'title': 'دعاء الاستيقاظ',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'meaning': 'شكر الله على نعمة الحياة بعد النوم',
      'category': 'النوم',
      'source': 'رواه البخاري',
    },
    {
      'title': 'دعاء قبل الطعام',
      'arabic': 'بِسْمِ اللَّهِ',
      'meaning': 'التسمية قبل الأكل',
      'category': 'الطعام',
      'source': 'متفق عليه',
    },
    {
      'title': 'دعاء بعد الطعام',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَٰذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      'meaning': 'شكر الله على نعمة الطعام',
      'category': 'الطعام',
      'source': 'رواه أبو داود والترمذي',
    },
    {
      'title': 'دعاء السفر',
      'arabic':
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
      'meaning': 'الاعتراف بفضل الله في تسخير وسائل السفر',
      'category': 'السفر',
      'source': 'رواه مسلم',
    },
    {
      'title': 'دعاء الركوع',
      'arabic': 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      'meaning': 'تنزيه الله عن كل نقص',
      'category': 'الصلاة',
      'source': 'رواه مسلم',
    },
    {
      'title': 'دعاء السجود',
      'arabic': 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      'meaning': 'تنزيه الله العلي عن كل نقص',
      'category': 'الصلاة',
      'source': 'رواه مسلم',
    },
    {
      'title': 'دعاء الكرب',
      'arabic':
          'لَا إِلَٰهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَٰهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَٰهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
      'meaning': 'دعاء لتفريج الكرب والهم',
      'category': 'الاستغفار',
      'source': 'متفق عليه',
    },
  ];

  List<Map<String, dynamic>> get _filteredDuas {
    if (_selectedCategory == 'الكل') {
      return _duas;
    }
    return _duas.where((dua) => dua['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'الأدعية المأثورة',
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                  ),
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

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(category['name'] as String),
                          ],
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category['name'] as String;
                          });
                        },
                        selectedColor: colorScheme.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Duas List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildDuaCard(_filteredDuas[index], colorScheme),
                  childCount: _filteredDuas.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dua['title'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dua['category'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share(
                      '${dua['title']}\n\n${dua['arabic']}\n\n${dua['meaning']}\n\n${dua['source']}\n\nمن تطبيق أنا مسلم',
                    );
                  },
                ),
              ],
            ),
          ),

          // Arabic Text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              dua['arabic'] as String,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Meaning
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dua['meaning'] as String,
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Source
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.menu_book, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  dua['source'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

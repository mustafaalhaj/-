import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_background.dart';

class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  int? _selectedIndex;

  final List<Map<String, String>> _names = [
    {
      'name': 'الله',
      'transliteration': 'Allah',
      'meaning': 'الإله المعبود بحق',
    },
    {
      'name': 'الرَّحْمَنُ',
      'transliteration': 'Ar-Rahman',
      'meaning': 'الذي وسعت رحمته كل شيء',
    },
    {
      'name': 'الرَّحِيمُ',
      'transliteration': 'Ar-Raheem',
      'meaning': 'المنعم أبداً على عباده',
    },
    {
      'name': 'الْمَلِكُ',
      'transliteration': 'Al-Malik',
      'meaning': 'المتصرف في ملكه كيف يشاء',
    },
    {
      'name': 'الْقُدُّوسُ',
      'transliteration': 'Al-Quddus',
      'meaning': 'المنزه عن كل نقص',
    },
    {
      'name': 'السَّلَامُ',
      'transliteration': 'As-Salam',
      'meaning': 'السالم من كل عيب',
    },
    {
      'name': 'الْمُؤْمِنُ',
      'transliteration': 'Al-Mu\'min',
      'meaning': 'المصدق لرسله بالآيات',
    },
    {
      'name': 'الْمُهَيْمِنُ',
      'transliteration': 'Al-Muhaymin',
      'meaning': 'الرقيب على خلقه',
    },
    {
      'name': 'الْعَزِيزُ',
      'transliteration': 'Al-Aziz',
      'meaning': 'الغالب الذي لا يُغلب',
    },
    {
      'name': 'الْجَبَّارُ',
      'transliteration': 'Al-Jabbar',
      'meaning': 'الذي يجبر الكسير',
    },
    {
      'name': 'الْمُتَكَبِّرُ',
      'transliteration': 'Al-Mutakabbir',
      'meaning': 'المتعالي عن صفات الخلق',
    },
    {
      'name': 'الْخَالِقُ',
      'transliteration': 'Al-Khaliq',
      'meaning': 'الموجد للأشياء من العدم',
    },
    {
      'name': 'الْبَارِئُ',
      'transliteration': 'Al-Bari\'',
      'meaning': 'المميز للمخلوقات',
    },
    {
      'name': 'الْمُصَوِّرُ',
      'transliteration': 'Al-Musawwir',
      'meaning': 'المصور لخلقه كيف يشاء',
    },
    {
      'name': 'الْغَفَّارُ',
      'transliteration': 'Al-Ghaffar',
      'meaning': 'الساتر لذنوب عباده',
    },
    {
      'name': 'الْقَهَّارُ',
      'transliteration': 'Al-Qahhar',
      'meaning': 'الذي قهر جميع المخلوقات',
    },
    {
      'name': 'الْوَهَّابُ',
      'transliteration': 'Al-Wahhab',
      'meaning': 'كثير العطاء والهبات',
    },
    {
      'name': 'الرَّزَّاقُ',
      'transliteration': 'Ar-Razzaq',
      'meaning': 'المتكفل بأرزاق العباد',
    },
    {
      'name': 'الْفَتَّاحُ',
      'transliteration': 'Al-Fattah',
      'meaning': 'الذي يفتح أبواب الرحمة',
    },
    {
      'name': 'الْعَلِيمُ',
      'transliteration': 'Al-Alim',
      'meaning': 'الذي يعلم كل شيء',
    },
    {
      'name': 'الْقَابِضُ',
      'transliteration': 'Al-Qabid',
      'meaning': 'الذي يقبض الأرزاق',
    },
    {
      'name': 'الْبَاسِطُ',
      'transliteration': 'Al-Basit',
      'meaning': 'الذي يبسط الرزق لمن يشاء',
    },
    {
      'name': 'الْخَافِضُ',
      'transliteration': 'Al-Khafid',
      'meaning': 'الذي يخفض الكافرين',
    },
    {
      'name': 'الرَّافِعُ',
      'transliteration': 'Ar-Rafi\'',
      'meaning': 'الذي يرفع المؤمنين',
    },
    {
      'name': 'الْمُعِزُّ',
      'transliteration': 'Al-Mu\'izz',
      'meaning': 'الذي يعز من يشاء',
    },
    {
      'name': 'الْمُذِلُّ',
      'transliteration': 'Al-Mudhill',
      'meaning': 'الذي يذل من يشاء',
    },
    {
      'name': 'السَّمِيعُ',
      'transliteration': 'As-Sami\'',
      'meaning': 'الذي يسمع كل شيء',
    },
    {
      'name': 'الْبَصِيرُ',
      'transliteration': 'Al-Basir',
      'meaning': 'الذي يبصر كل شيء',
    },
    {
      'name': 'الْحَكَمُ',
      'transliteration': 'Al-Hakam',
      'meaning': 'الحاكم بين عباده',
    },
    {
      'name': 'الْعَدْلُ',
      'transliteration': 'Al-Adl',
      'meaning': 'العادل في حكمه',
    },
    {
      'name': 'اللَّطِيفُ',
      'transliteration': 'Al-Latif',
      'meaning': 'الرفيق بعباده',
    },
    {
      'name': 'الْخَبِيرُ',
      'transliteration': 'Al-Khabir',
      'meaning': 'العالم بدقائق الأمور',
    },
    {
      'name': 'الْحَلِيمُ',
      'transliteration': 'Al-Halim',
      'meaning': 'الذي لا يعجل بالعقوبة',
    },
    {
      'name': 'الْعَظِيمُ',
      'transliteration': 'Al-Azim',
      'meaning': 'الجامع لصفات العظمة',
    },
    {
      'name': 'الْغَفُورُ',
      'transliteration': 'Al-Ghafur',
      'meaning': 'الذي يغفر الذنوب',
    },
    {
      'name': 'الشَّكُورُ',
      'transliteration': 'Ash-Shakur',
      'meaning': 'المثيب على القليل بالكثير',
    },
    {
      'name': 'الْعَلِيُّ',
      'transliteration': 'Al-Ali',
      'meaning': 'العلي فوق خلقه',
    },
    {
      'name': 'الْكَبِيرُ',
      'transliteration': 'Al-Kabir',
      'meaning': 'الكبير في ذاته وصفاته',
    },
    {
      'name': 'الْحَفِيظُ',
      'transliteration': 'Al-Hafiz',
      'meaning': 'الحافظ لكل شيء',
    },
    {
      'name': 'الْمُقِيتُ',
      'transliteration': 'Al-Muqit',
      'meaning': 'المقتدر على كل شيء',
    },
    {
      'name': 'الْحَسِيبُ',
      'transliteration': 'Al-Hasib',
      'meaning': 'الكافي لعباده',
    },
    {
      'name': 'الْجَلِيلُ',
      'transliteration': 'Al-Jalil',
      'meaning': 'الموصوف بالجلال',
    },
    {
      'name': 'الْكَرِيمُ',
      'transliteration': 'Al-Karim',
      'meaning': 'الجواد المنعم',
    },
    {
      'name': 'الرَّقِيبُ',
      'transliteration': 'Ar-Raqib',
      'meaning': 'الذي لا يغيب عنه شيء',
    },
    {
      'name': 'الْمُجِيبُ',
      'transliteration': 'Al-Mujib',
      'meaning': 'الذي يجيب دعاء الداعين',
    },
    {
      'name': 'الْوَاسِعُ',
      'transliteration': 'Al-Wasi\'',
      'meaning': 'الواسع رحمته وعلمه',
    },
    {
      'name': 'الْحَكِيمُ',
      'transliteration': 'Al-Hakim',
      'meaning': 'الذي يضع الأمور في محلها',
    },
    {
      'name': 'الْوَدُودُ',
      'transliteration': 'Al-Wadud',
      'meaning': 'المحب لعباده',
    },
    {
      'name': 'الْمَجِيدُ',
      'transliteration': 'Al-Majid',
      'meaning': 'ذو المجد والكرم',
    },
    {
      'name': 'الْبَاعِثُ',
      'transliteration': 'Al-Ba\'ith',
      'meaning': 'الذي يبعث الخلق يوم القيامة',
    },
    {
      'name': 'الشَّهِيدُ',
      'transliteration': 'Ash-Shahid',
      'meaning': 'الذي لا يغيب عنه شيء',
    },
    {
      'name': 'الْحَقُّ',
      'transliteration': 'Al-Haqq',
      'meaning': 'الثابت الموجود حقاً',
    },
    {
      'name': 'الْوَكِيلُ',
      'transliteration': 'Al-Wakil',
      'meaning': 'المتكفل بأمور عباده',
    },
    {
      'name': 'الْقَوِيُّ',
      'transliteration': 'Al-Qawiyy',
      'meaning': 'التام القدرة',
    },
    {
      'name': 'الْمَتِينُ',
      'transliteration': 'Al-Matin',
      'meaning': 'الشديد القوة',
    },
    {
      'name': 'الْوَلِيُّ',
      'transliteration': 'Al-Waliyy',
      'meaning': 'الناصر لعباده',
    },
    {
      'name': 'الْحَمِيدُ',
      'transliteration': 'Al-Hamid',
      'meaning': 'المحمود على كل حال',
    },
    {
      'name': 'الْمُحْصِي',
      'transliteration': 'Al-Muhsi',
      'meaning': 'الذي أحصى كل شيء',
    },
    {
      'name': 'الْمُبْدِئُ',
      'transliteration': 'Al-Mubdi\'',
      'meaning': 'الذي بدأ الخلق',
    },
    {
      'name': 'الْمُعِيدُ',
      'transliteration': 'Al-Mu\'id',
      'meaning': 'الذي يعيد الخلق بعد فنائهم',
    },
    {
      'name': 'الْمُحْيِي',
      'transliteration': 'Al-Muhyi',
      'meaning': 'الذي يحيي الموتى',
    },
    {
      'name': 'الْمُمِيتُ',
      'transliteration': 'Al-Mumit',
      'meaning': 'الذي يميت الأحياء',
    },
    {
      'name': 'الْحَيُّ',
      'transliteration': 'Al-Hayy',
      'meaning': 'الدائم الحياة',
    },
    {
      'name': 'الْقَيُّومُ',
      'transliteration': 'Al-Qayyum',
      'meaning': 'القائم بذاته',
    },
    {
      'name': 'الْوَاجِدُ',
      'transliteration': 'Al-Wajid',
      'meaning': 'الغني الذي لا يفتقر',
    },
    {
      'name': 'الْمَاجِدُ',
      'transliteration': 'Al-Majid',
      'meaning': 'ذو المجد والشرف',
    },
    {
      'name': 'الْوَاحِدُ',
      'transliteration': 'Al-Wahid',
      'meaning': 'المنفرد بالألوهية',
    },
    {
      'name': 'الصَّمَدُ',
      'transliteration': 'As-Samad',
      'meaning': 'الذي يُقصد في الحوائج',
    },
    {
      'name': 'الْقَادِرُ',
      'transliteration': 'Al-Qadir',
      'meaning': 'الذي يقدر على كل شيء',
    },
    {
      'name': 'الْمُقْتَدِرُ',
      'transliteration': 'Al-Muqtadir',
      'meaning': 'التام القدرة',
    },
    {
      'name': 'الْمُقَدِّمُ',
      'transliteration': 'Al-Muqaddim',
      'meaning': 'الذي يقدم من يشاء',
    },
    {
      'name': 'الْمُؤَخِّرُ',
      'transliteration': 'Al-Mu\'akhkhir',
      'meaning': 'الذي يؤخر من يشاء',
    },
    {
      'name': 'الأَوَّلُ',
      'transliteration': 'Al-Awwal',
      'meaning': 'الذي ليس قبله شيء',
    },
    {
      'name': 'الآخِرُ',
      'transliteration': 'Al-Akhir',
      'meaning': 'الباقي بعد فناء خلقه',
    },
    {
      'name': 'الظَّاهِرُ',
      'transliteration': 'Az-Zahir',
      'meaning': 'الظاهر بآياته',
    },
    {
      'name': 'الْبَاطِنُ',
      'transliteration': 'Al-Batin',
      'meaning': 'المحتجب عن الأبصار',
    },
    {
      'name': 'الْوَالِي',
      'transliteration': 'Al-Wali',
      'meaning': 'المتولي لأمور خلقه',
    },
    {
      'name': 'الْمُتَعَالِي',
      'transliteration': 'Al-Muta\'ali',
      'meaning': 'المتعالي عن خلقه',
    },
    {
      'name': 'الْبَرُّ',
      'transliteration': 'Al-Barr',
      'meaning': 'العطوف على عباده',
    },
    {
      'name': 'التَّوَّابُ',
      'transliteration': 'At-Tawwab',
      'meaning': 'الذي يقبل التوبة',
    },
    {
      'name': 'الْمُنْتَقِمُ',
      'transliteration': 'Al-Muntaqim',
      'meaning': 'الذي ينتقم من العصاة',
    },
    {
      'name': 'العَفُوُّ',
      'transliteration': 'Al-Afuww',
      'meaning': 'الذي يعفو عن الذنوب',
    },
    {
      'name': 'الرَّؤُوفُ',
      'transliteration': 'Ar-Ra\'uf',
      'meaning': 'الرحيم بعباده',
    },
    {
      'name': 'مَالِكُ الْمُلْكِ',
      'transliteration': 'Malik-ul-Mulk',
      'meaning': 'المتصرف في ملكه',
    },
    {
      'name': 'ذُو الْجَلَالِ وَالْإِكْرَامِ',
      'transliteration': 'Dhul-Jalal-wal-Ikram',
      'meaning': 'صاحب العظمة والكرم',
    },
    {
      'name': 'الْمُقْسِطُ',
      'transliteration': 'Al-Muqsit',
      'meaning': 'العادل في حكمه',
    },
    {
      'name': 'الْجَامِعُ',
      'transliteration': 'Al-Jami\'',
      'meaning': 'الذي يجمع الخلائق',
    },
    {
      'name': 'الْغَنِيُّ',
      'transliteration': 'Al-Ghani',
      'meaning': 'المستغني عن خلقه',
    },
    {
      'name': 'الْمُغْنِي',
      'transliteration': 'Al-Mughni',
      'meaning': 'الذي يغني من يشاء',
    },
    {
      'name': 'الْمَانِعُ',
      'transliteration': 'Al-Mani\'',
      'meaning': 'الذي يمنع عمن يشاء',
    },
    {
      'name': 'الضَّارُّ',
      'transliteration': 'Ad-Darr',
      'meaning': 'الذي يضر من يشاء',
    },
    {
      'name': 'النَّافِعُ',
      'transliteration': 'An-Nafi\'',
      'meaning': 'الذي ينفع من يشاء',
    },
    {
      'name': 'النُّورُ',
      'transliteration': 'An-Nur',
      'meaning': 'نور السماوات والأرض',
    },
    {
      'name': 'الْهَادِي',
      'transliteration': 'Al-Hadi',
      'meaning': 'الذي يهدي من يشاء',
    },
    {
      'name': 'الْبَدِيعُ',
      'transliteration': 'Al-Badi\'',
      'meaning': 'المبدع لخلقه',
    },
    {
      'name': 'الْبَاقِي',
      'transliteration': 'Al-Baqi',
      'meaning': 'الدائم الوجود',
    },
    {
      'name': 'الْوَارِثُ',
      'transliteration': 'Al-Warith',
      'meaning': 'الباقي بعد فناء خلقه',
    },
    {
      'name': 'الرَّشِيدُ',
      'transliteration': 'Ar-Rashid',
      'meaning': 'الذي يرشد خلقه',
    },
    {
      'name': 'الصَّبُورُ',
      'transliteration': 'As-Sabur',
      'meaning': 'الذي لا يعجل بالعقوبة',
    },
  ];

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
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'أسماء الله الحسنى',
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        const Color(0xFF1B5E20),
                        const Color(0xFF2E7D32).withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.brightness_7,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: Text(
                          '99',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Grid of names
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildNameCard(index, colorScheme),
                  childCount: _names.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameCard(int index, ColorScheme colorScheme) {
    final name = _names[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
        if (!isSelected) {
          _showNameDetails(name);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                : [colorScheme.surface, colorScheme.surface],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B5E20)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : colorScheme.primaryContainer.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              name['name']!,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Transliteration
            Text(
              name['transliteration']!,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNameDetails(Map<String, String> name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Name
            Text(
              name['name']!,
              style: GoogleFonts.amiri(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name['transliteration']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            // Meaning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name['meaning']!,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

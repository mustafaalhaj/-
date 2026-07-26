class MoodData {
  final String label;
  final String emoji;
  final List<MoodContent> content;
  final int color; // Material Color value

  MoodData({
    required this.label,
    required this.emoji,
    required this.content,
    required this.color,
  });
}

class MoodContent {
  final String text;
  final String source; // "Surah X, Ayah Y" or "Hadith..."
  final String type; // "quran" or "hadith" or "dua"

  MoodContent({required this.text, required this.source, required this.type});
}

class MoodRepository {
  static final List<MoodData> moods = [
    MoodData(
      label: "سعيد",
      emoji: "😊",
      color: 0xFF4CAF50, // Green
      content: [
        MoodContent(
          text:
              "قُلْ بِفَضْلِ اللَّهِ وَبِرَحْمَتِهِ فَبِذَٰلِكَ فَلْيَفْرَحُوا هُوَ خَيْرٌ مِّمَّا يَجْمَعُونَ",
          source: "سورة يونس - 58",
          type: "quran",
        ),
        MoodContent(
          text: "لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
          source: "سورة إبراهيم - 7",
          type: "quran",
        ),
        MoodContent(
          text: "اللهم لك الحمد كما ينبغي لجلال وجهك وعظيم سلطانك",
          source: "دعاء",
          type: "dua",
        ),
      ],
    ),
    MoodData(
      label: "حزين",
      emoji: "😔",
      color: 0xFF607D8B, // Blue Grey
      content: [
        MoodContent(
          text: "لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا",
          source: "سورة التوبة - 40",
          type: "quran",
        ),
        MoodContent(
          text: "إِنَّمَا أَشْكُو بَثِّي وَhُزْنِي إِلَى اللَّهِ",
          source: "سورة يوسف - 86",
          type: "quran",
        ),
        MoodContent(
          text: "اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل",
          source: "حديث شريف",
          type: "dua",
        ),
      ],
    ),
    MoodData(
      label: "قلق",
      emoji: "😰",
      color: 0xFF9C27B0, // Purple
      content: [
        MoodContent(
          text: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
          source: "سورة الرعد - 28",
          type: "quran",
        ),
        MoodContent(
          text: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
          source: "سورة آل عمران - 173",
          type: "quran",
        ),
        MoodContent(
          text:
              "اللهم لا سهل إلا ما جعلته سهلاً، وأنت تجعل الحزن إذا شئت سهلاً",
          source: "دعاء",
          type: "dua",
        ),
      ],
    ),
    MoodData(
      label: "غاضب",
      emoji: "😡",
      color: 0xFFF44336, // Red
      content: [
        MoodContent(
          text:
              "وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ",
          source: "سورة آل عمران - 134",
          type: "quran",
        ),
        MoodContent(
          text: "استعذ بالله من الشيطان الرجيم",
          source: "وصية نبوية",
          type: "dua",
        ),
      ],
    ),
    MoodData(
      label: "وحيد",
      emoji: "🙍‍♂️",
      color: 0xFF3F51B5, // Indigo
      content: [
        MoodContent(
          text: "وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ",
          source: "سورة ق - 16",
          type: "quran",
        ),
        MoodContent(
          text: "أَلَيْسَ اللَّهُ بِكَافٍ عَبْدَهُ",
          source: "سورة الزمر - 36",
          type: "quran",
        ),
      ],
    ),
    MoodData(
      label: "متردد",
      emoji: "🤔",
      color: 0xFFFF9800, // Orange
      content: [
        MoodContent(
          text:
              "وَشَاوِرْهُمْ فِي الْأَمْرِ ۖ فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ",
          source: "سورة آل عمران - 159",
          type: "quran",
        ),
        MoodContent(
          text: "اللهم إني أستخيرك بعلمك، وأستقدرك بقدرتك",
          source: "دعاء الاستخارة",
          type: "dua",
        ),
      ],
    ),
  ];
}

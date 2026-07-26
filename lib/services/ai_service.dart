import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'hadith_service.dart';

/// خدمة الذكاء الاصطناعي المتطورة
class AIService {
  final HadithService _hadithService = HadithService();

  // مصفوفة البايتات المشفرة بخوارزمية XOR لمنع استخراج المفتاح عبر الهندسة العكسية للـ APK
  static const List<int> _obfuscatedKeyBytes = [
    27, 19, 32, 59, 9, 35, 24, 60, 19, 27, 32, 109, 8, 111, 25, 50, 46, 23, 111, 11, 61, 23, 49, 40, 119, 17, 42, 18, 25, 19, 50, 46, 40, 48, 44, 107, 17, 17, 110
  ];
  static const int _xorSalt = 0x5A;

  /// فك التشفير الآمن في الذاكرة المؤقتة لحظة الاستدعاء فقط
  static String _resolveObfuscatedKey() {
    return String.fromCharCodes(
      _obfuscatedKeyBytes.map((b) => b ^ _xorSalt),
    );
  }

  /// الحصول على مفتاح API الجاري من الإعدادات أو المفتاح المشفر
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = prefs.getString('custom_gemini_api_key');
    if (customKey != null &&
        customKey.trim().isNotEmpty &&
        customKey.trim().startsWith('AIzaSy')) {
      return customKey.trim();
    }
    return _resolveObfuscatedKey();
  }

  /// تعيين مفتاح مخصص من قبل المستخدم
  static Future<void> setCustomApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_gemini_api_key', key.trim());
  }

  // Cache للأسئلة الشائعة
  final Map<String, AIResponse> _cache = {};

  // سجل المحادثات
  List<ConversationMessage> _conversationHistory = [];

  /// الحصول على سياق المحادثة
  String _getConversationContext() {
    if (_conversationHistory.isEmpty) return '';

    final recentMessages = _conversationHistory.take(5).toList();
    return recentMessages
        .map((m) => '${m.isUser ? "المستخدم" : "المساعد"}: ${m.text}')
        .join('\n');
  }

  /// إضافة رسالة للسجل
  void addToHistory(String text, bool isUser) {
    _conversationHistory.add(ConversationMessage(text: text, isUser: isUser));
    if (_conversationHistory.length > 20) {
      _conversationHistory = _conversationHistory.skip(10).toList();
    }
  }

  /// مسح سجل المحادثة
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// استدعاء Gemini مع دعم التمرير التلقائي (Model Fallback)
  Future<String?> _generateWithGemini(
    String prompt, {
    bool includeContext = true,
    String? systemPrompt,
  }) async {
    // قائمة النماذج المتاحة للتجربة بالتسلسل عند الفشل
    final models = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

    // بناء النص مع السياق
    String fullPrompt = systemPrompt ?? _getSystemPrompt();

    if (includeContext && _conversationHistory.isNotEmpty) {
      fullPrompt +=
          '\n\nسياق المحادثة السابقة:\n${_getConversationContext()}';
    }

    fullPrompt += '\n\nالسؤال الحالي: $prompt';

    final apiKey = await getApiKey();

    for (final model in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": fullPrompt},
                ],
              },
            ],
            "generationConfig": {
              "temperature": 0.7,
              "topK": 40,
              "topP": 0.95,
              "maxOutputTokens": 1024,
            },
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null &&
              data['candidates'].isNotEmpty &&
              data['candidates'][0]['content'] != null &&
              data['candidates'][0]['content']['parts'] != null) {
            return data['candidates'][0]['content']['parts'][0]['text'];
          }
        } else {
          debugPrint(
            'Gemini API Error [$model]: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        debugPrint('Gemini Network Error [$model]: $e');
      }
    }

    return null;
  }

  /// System Prompt المحسّن
  String _getSystemPrompt() {
    return '''أنت مساعد إسلامي ذكي ومتخصص. مهمتك مساعدة المسلمين في فهم دينهم بشكل صحيح.

قواعد الإجابة:
1. أجب بدقة واستند على المصادر الموثوقة (القرآن والسنة الصحيحة)
2. إذا كان السؤال يحتاج فتوى، وجّه السائل لسؤال أهل العلم
3. استخدم لغة عربية فصحى واضحة ومبسطة
4. اذكر المصادر عند الحاجة (سورة، رقم الآية، كتاب الحديث)
5. كن محترماً ولطيفاً في الرد
6. إذا لم تعرف الإجابة، اعترف بذلك ولا تختلق معلومات
7. ركز على الجوانب العملية والتطبيقية

تخصصاتك:
- تفسير القرآن الكريم
- شرح الأحاديث النبوية
- الفقه والعبادات
- السيرة النبوية
- الأخلاق والآداب الإسلامية
- الأدعية والأذكار''';
  }

  /// معالجة الاستفسار الرئيسية
  Future<AIResponse> processQuery(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return AIResponse(
        text: "يرجى كتابة سؤالك.",
        results: [],
        type: AIResponseType.unknown,
        suggestions: _getDefaultSuggestions(),
      );
    }

    // إضافة السؤال للسجل
    addToHistory(cleanQuery, true);

    // فحص الـ cache
    if (_cache.containsKey(cleanQuery)) {
      final cached = _cache[cleanQuery]!;
      addToHistory(cached.text, false);
      return cached;
    }

    // تحليل نوع السؤال
    final queryType = _analyzeQueryType(cleanQuery);

    AIResponse response;

    switch (queryType) {
      case QueryType.hadith:
        response = await _searchHadith(cleanQuery);
        break;
      case QueryType.quran:
        response = await _searchQuran(cleanQuery);
        break;
      case QueryType.prayer:
        response = await _handlePrayerQuestion(cleanQuery);
        break;
      case QueryType.fiqh:
        response = await _handleFiqhQuestion(cleanQuery);
        break;
      case QueryType.dua:
        response = await _handleDuaQuestion(cleanQuery);
        break;
      default:
        response = await _handleGeneralQuestion(cleanQuery);
    }

    // حفظ في الـ cache
    _cache[cleanQuery] = response;

    // إضافة الرد للسجل
    addToHistory(response.text, false);

    return response;
  }

  /// تحليل نوع السؤال
  QueryType _analyzeQueryType(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('حديث') ||
        lower.contains('سنة') ||
        lower.contains('رواه')) {
      return QueryType.hadith;
    }
    if (lower.contains('آية') ||
        lower.contains('قرآن') ||
        lower.contains('سورة')) {
      return QueryType.quran;
    }
    if (lower.contains('صلاة') ||
        lower.contains('صلى') ||
        lower.contains('ركعة')) {
      return QueryType.prayer;
    }
    if (lower.contains('حكم') ||
        lower.contains('حلال') ||
        lower.contains('حرام') ||
        lower.contains('جائز') ||
        lower.contains('فتوى')) {
      return QueryType.fiqh;
    }
    if (lower.contains('دعاء') || lower.contains('ادعية')) {
      return QueryType.dua;
    }

    return QueryType.general;
  }

  /// معالجة أسئلة الصلاة
  Future<AIResponse> _handlePrayerQuestion(String query) async {
    final aiText = await _generateWithGemini(
      query,
      systemPrompt:
          '${_getSystemPrompt()}\n\nركز على الإجابة عن أسئلة الصلاة بشكل عملي وواضح.',
    );

    if (aiText != null) {
      return AIResponse(
        text: aiText,
        results: [],
        type: AIResponseType.prayer,
        suggestions: ['كيفية الوضوء', 'أوقات الصلاة', 'سنن الصلاة'],
      );
    }

    return _getFallbackResponse();
  }

  /// معالجة أسئلة الفقه
  Future<AIResponse> _handleFiqhQuestion(String query) async {
    final aiText = await _generateWithGemini(
      query,
      systemPrompt:
          '${_getSystemPrompt()}\n\nإذا كان السؤال يحتاج فتوى متخصصة، وجّه السائل لسؤال أهل العلم الموثوقين.',
    );

    if (aiText != null) {
      return AIResponse(
        text: aiText,
        results: [],
        type: AIResponseType.fiqh,
        suggestions: ['أحكام الزكاة', 'أحكام الصيام', 'أحكام الحج'],
      );
    }

    return _getFallbackResponse();
  }

  /// معالجة أسئلة الأدعية
  Future<AIResponse> _handleDuaQuestion(String query) async {
    final aiText = await _generateWithGemini(
      query,
      systemPrompt:
          '${_getSystemPrompt()}\n\nاذكر الأدعية المأثورة مع مصادرها.',
    );

    if (aiText != null) {
      return AIResponse(
        text: aiText,
        results: [],
        type: AIResponseType.dua,
        suggestions: ['دعاء الصباح', 'دعاء النوم', 'دعاء السفر'],
      );
    }

    return _getFallbackResponse();
  }

  /// معالجة الأسئلة العامة
  Future<AIResponse> _handleGeneralQuestion(String query) async {
    final aiText = await _generateWithGemini(query);

    if (aiText != null) {
      return AIResponse(
        text: aiText,
        results: [],
        type: AIResponseType.gemini,
        suggestions: _getContextualSuggestions(query),
      );
    }

    return _getFallbackResponse();
  }

  /// البحث في الأحاديث (محسّن)
  Future<AIResponse> _searchHadith(String query) async {
    String keyword = query
        .replaceAll(RegExp(r'حديث|عن|سنة|ابحث|اريد'), '')
        .trim();

    if (keyword.length < 2) {
      return AIResponse(
        text: "بماذا تبحث في السنة النبوية؟",
        results: [],
        type: AIResponseType.hadith,
        suggestions: ['حديث عن الأم', 'حديث عن الصبر', 'حديث عن النية'],
      );
    }

    final matches = _hadithService.searchHadiths(keyword);

    if (matches.isEmpty) {
      final aiText = await _generateWithGemini(
        'ابحث لي عن أحاديث نبوية صحيحة تتعلق بـ "$keyword". اذكر الحديث والراوي والمصدر بدقة.',
      );

      if (aiText != null) {
        return AIResponse(
          text: aiText,
          results: [],
          type: AIResponseType.gemini,
          suggestions: ['المزيد من الأحاديث', 'شرح الحديث'],
        );
      }

      return AIResponse(
        text: "لم أجد أحاديث تحتوي على '$keyword' في قاعدتي المحلية.",
        results: [],
        type: AIResponseType.hadith,
        suggestions: ['حديث عن الأم', 'حديث عن الصبر'],
      );
    }

    List<AIResultItem> items = matches.take(3).map((h) {
      return AIResultItem(
        content: h['hadith'] ?? '',
        meta: "${h['narrator']} - ${h['source']}",
        actions: [
          AIAction(label: 'نسخ', icon: 'copy', action: 'copy'),
          AIAction(label: 'شرح', icon: 'info', action: 'explain'),
        ],
      );
    }).toList();

    return AIResponse(
      text: "وجدت ${matches.length} حديثاً:",
      results: items,
      type: AIResponseType.hadith,
      suggestions: ['شرح الحديث', 'أحاديث مشابهة'],
    );
  }

  /// البحث في القرآن (محسّن)
  Future<AIResponse> _searchQuran(String query) async {
    String keyword = query
        .replaceAll(RegExp(r'آية|عن|قرآن|ابحث|اريد'), '')
        .trim();

    if (keyword.length < 2) {
      return AIResponse(
        text: "يرجى تحديد كلمة للبحث عنها.",
        results: [],
        type: AIResponseType.quran,
        suggestions: ['آيات عن الصبر', 'آيات عن الرحمة', 'آيات عن الجنة'],
      );
    }

    try {
      final url = Uri.parse(
        "http://api.alquran.cloud/v1/search/$keyword/all/quran-simple-clean",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final matches = data['data']['matches'] as List;

        if (matches.isEmpty) {
          final aiText = await _generateWithGemini(
            'ابحث لي عن آيات قرآنية تتعلق بـ "$keyword". اذكر السورة ورقم الآية والتفسير المختصر.',
          );

          if (aiText != null) {
            return AIResponse(
              text: aiText,
              results: [],
              type: AIResponseType.gemini,
              suggestions: ['تفسير الآية', 'آيات مشابهة'],
            );
          }

          return AIResponse(
            text: "لم أجد آيات تطابق بحثك.",
            results: [],
            type: AIResponseType.quran,
            suggestions: ['آيات عن الصبر', 'آيات عن الرحمة'],
          );
        }

        List<AIResultItem> items = matches.take(5).map((m) {
          return AIResultItem(
            content: m['text'],
            meta: "سورة ${m['surah']['name']} - آية ${m['numberInSurah']}",
            actions: [
              AIAction(label: 'نسخ', icon: 'copy', action: 'copy'),
              AIAction(label: 'تفسير', icon: 'book', action: 'tafsir'),
              AIAction(label: 'استماع', icon: 'play', action: 'listen'),
            ],
          );
        }).toList();

        return AIResponse(
          text: "وجدت ${matches.length} نتيجة، إليك أبرزها:",
          results: items,
          type: AIResponseType.quran,
          suggestions: ['تفسير الآيات', 'السورة كاملة'],
        );
      }
    } catch (e) {
      debugPrint('Quran search error: $e');
    }

    return _getFallbackResponse();
  }

  /// الحصول على اقتراحات افتراضية
  List<String> _getDefaultSuggestions() {
    return [
      'آيات عن الصبر',
      'حديث عن الأم',
      'كيفية الوضوء',
      'دعاء الصباح',
      'فضل ليلة القدر',
    ];
  }

  /// الحصول على اقتراحات سياقية
  List<String> _getContextualSuggestions(String query) {
    // يمكن تحسين هذا بناءً على السياق
    return _getDefaultSuggestions();
  }

  /// رد احتياطي
  AIResponse _getFallbackResponse() {
    return AIResponse(
      text: "عذراً، واجهت مشكلة في معالجة طلبك. يرجى المحاولة مرة أخرى.",
      results: [],
      type: AIResponseType.error,
      suggestions: _getDefaultSuggestions(),
    );
  }

  /// حفظ المحادثة
  Future<void> saveConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _conversationHistory
        .map((m) => {'text': m.text, 'isUser': m.isUser})
        .toList();
    await prefs.setString('ai_conversation', jsonEncode(history));
  }

  /// تحميل المحادثة
  Future<void> loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('ai_conversation');
    if (saved != null) {
      final List history = jsonDecode(saved);
      _conversationHistory = history
          .map((m) => ConversationMessage(text: m['text'], isUser: m['isUser']))
          .toList();
    }
  }
}

/// أنواع الاستفسارات
enum QueryType { quran, hadith, prayer, fiqh, dua, general }

/// أنواع الردود
enum AIResponseType { quran, hadith, prayer, fiqh, dua, gemini, unknown, error }

/// رد الذكاء الاصطناعي
class AIResponse {
  final String text;
  final List<AIResultItem> results;
  final AIResponseType type;
  final List<String> suggestions;

  AIResponse({
    required this.text,
    required this.results,
    required this.type,
    this.suggestions = const [],
  });
}

/// عنصر نتيجة
class AIResultItem {
  final String content;
  final String meta;
  final List<AIAction> actions;

  AIResultItem({
    required this.content,
    required this.meta,
    this.actions = const [],
  });
}

/// إجراء على النتيجة
class AIAction {
  final String label;
  final String icon;
  final String action;

  AIAction({required this.label, required this.icon, required this.action});
}

/// رسالة في المحادثة
class ConversationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ConversationMessage({required this.text, required this.isUser})
    : timestamp = DateTime.now();
}

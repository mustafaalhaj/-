import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class QuranService {
  static const String _baseUrl = 'http://api.alquran.cloud/v1';

  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        return surahsJson.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<Map<String, dynamic>> getSurahDetails(int number) async {
    // Fetch Arabic text, English translation, French translation, and audio
    // http://api.alquran.cloud/v1/surah/1/editions/quran-uthmani,en.asad,fr.hamidullah,ar.alafasy
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/surah/$number/editions/quran-uthmani,en.asad,fr.hamidullah,ar.alafasy',
        ),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load surah details');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/surah.dart';
import '../services/quran_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/audio_player_bar.dart';
import '../widgets/glass_background.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranService _quranService = QuranService();
  final AudioPlayerService _audioService = AudioPlayerService();

  List<dynamic> _arabicVerses = [];
  List<dynamic> _englishVerses = [];
  List<dynamic> _frenchVerses = [];
  List<dynamic> _audioVerses = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  int? _currentPlayingIndex;

  @override
  void initState() {
    super.initState();
    _loadSurahDetails();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    // Duration and Position listeners removed to prevent frequent rebuilds.
    // Handled internally by AudioPlayerBar.

    _audioService.currentIndexStream.listen((index) {
      if (mounted && index != null) {
        setState(() {
          _currentPlayingIndex = index;
        });
      }
    });
  }

  Future<void> _loadSurahDetails() async {
    try {
      final data = await _quranService.getSurahDetails(widget.surah.number);
      if (!mounted) return;
      final editions = data['data'] as List;
      setState(() {
        _arabicVerses = editions[0]['ayahs'];
        _englishVerses = editions[1]['ayahs'];
        if (editions.length > 2) {
          _frenchVerses = editions[2]['ayahs'];
        }
        if (editions.length > 3) {
          _audioVerses = editions[3]['ayahs'];
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل السورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _playAudio(int index) async {
    if (_audioVerses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الصوت غير متوفر')));
      return;
    }

    try {
      // If already playing this index, just toggle play/pause
      if (_currentPlayingIndex == index && _audioService.playing) {
        await _audioService.pause();
        return;
      }

      // If playing different index or not playing, load new audio
      if (_currentPlayingIndex != index) {
        final audioUrls = _audioVerses
            .map((verse) => verse['audio'] as String)
            .toList();

        final mediaItems = _audioVerses.map((verse) {
          return MediaItem(
            id: '${widget.surah.number}_${verse['numberInSurah']}',
            album: 'القرآن الكريم',
            title: 'سورة ${widget.surah.name}',
            artist: 'مشاري العفاسي',
            artUri: Uri.parse(
              'https://cdn-icons-png.flaticon.com/512/4358/4358666.png',
            ),
          );
        }).toList();

        await _audioService.playAudioList(
          audioUrls: audioUrls,
          mediaItems: mediaItems,
          initialIndex: index,
        );

        setState(() {
          _currentPlayingIndex = index;
        });
      } else {
        await _audioService.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playFullSurah() async {
    await _playAudio(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Make body extend behind AppBar
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
                  widget.surah.name,
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          widget.surah.englishName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.surah.numberOfAyahs} آية • ${widget.surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!_isLoading && _audioVerses.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    tooltip: 'تشغيل السورة كاملة',
                    onPressed: _playFullSurah,
                  ),
              ],
            ),

            // Audio Player Bar (Isolated for performance)
            if (_isPlaying || _currentPlayingIndex != null)
              SliverToBoxAdapter(
                child: AudioPlayerBar(
                  audioService: _audioService,
                  currentPlayingIndex: _currentPlayingIndex,
                  isPlaying: _isPlaying,
                ),
              ),

            // Verses List
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final arabicVerse = _arabicVerses[index];
                        final englishVerse = _englishVerses.isNotEmpty
                            ? _englishVerses[index]
                            : null;
                        final frenchVerse = _frenchVerses.isNotEmpty
                            ? _frenchVerses[index]
                            : null;

                        final isCurrentlyPlaying =
                            _currentPlayingIndex == index && _isPlaying;

                        return _buildVerseCard(
                          index,
                          arabicVerse,
                          englishVerse,
                          frenchVerse,
                          isCurrentlyPlaying,
                          isDark,
                        );
                      }, childCount: _arabicVerses.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(
    int index,
    dynamic arabicVerse,
    dynamic englishVerse,
    dynamic frenchVerse,
    bool isCurrentlyPlaying,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Optimization: Removed ClipRRect and BackdropFilter for 60FPS scrolling.
      // Used semi-transparent colors to simulate glass effect cheaply.
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? const Color(0xFFFFD700).withValues(
                alpha: 0.15,
              ) // Highlight with Gold
            : (isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.85)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentlyPlaying
              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isCurrentlyPlaying ? 1.5 : 1,
        ),
        boxShadow: isCurrentlyPlaying
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Verse Number & Audio Button
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/icons/ayah_symbol.png',
                      ), // Ensure asset exists or use Shape
                      fit: BoxFit.contain,
                    ),
                    // Fallback decoration if image missing
                    color: const Color(0xFF009688).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF009688),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${arabicVerse['numberInSurah']}',
                      style: GoogleFonts.cairo(
                        color: isDark ? Colors.white : const Color(0xFF009688),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (_audioVerses.isNotEmpty)
                  InkWell(
                    onTap: () => _playAudio(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentlyPlaying
                            ? const Color(0xFFFFD700)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrentlyPlaying
                              ? Colors.transparent
                              : Colors.white30,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            isCurrentlyPlaying ? 'إيقاف' : 'استماع',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: isCurrentlyPlaying
                                  ? Colors.black
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isCurrentlyPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isCurrentlyPlaying
                                ? Colors.black
                                : Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Arabic Text
            Text(
              arabicVerse['text'],
              style: GoogleFonts.amiri(
                fontSize: 26,
                height: 2.2,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),

            // Translations Separator
            if (englishVerse != null || frenchVerse != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
              ),

            // English Translation
            if (englishVerse != null)
              Text(
                englishVerse['text'],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),

            // French Translation
            if (frenchVerse != null) ...[
              const SizedBox(height: 12),
              Text(
                frenchVerse['text'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black45,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

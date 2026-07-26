import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get player => _audioPlayer;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  Future<void> playAudioList({
    required List<String> audioUrls,
    required List<MediaItem>
    mediaItems, // Kept for API compatibility but ignored
    int initialIndex = 0,
  }) async {
    try {
      debugPrint(
        'AudioPlayerService: Starting playback with ${audioUrls.length} items',
      );

      if (audioUrls.isEmpty) {
        throw Exception('قائمة الصوتيات فارغة');
      }
      if (initialIndex >= audioUrls.length) {
        throw Exception('الفهرس المبدئي خارج النطاق');
      }

      // Simplified playback without background tags to avoid LateInitializationError
      final playlist = ConcatenatingAudioSource(
        children: List.generate(
          audioUrls.length,
          (index) => AudioSource.uri(
            Uri.parse(audioUrls[index]),
            // tag: mediaItems[index], // DISABLED to fix crash
          ),
        ),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );

      await _audioPlayer.play();
      debugPrint('AudioPlayerService: Playback started successfully');
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService ERROR: $e');
      debugPrint('AudioPlayerService Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> seekToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
  Stream<PlaybackEvent> get playbackEventStream =>
      _audioPlayer.playbackEventStream;

  bool get playing => _audioPlayer.playing;
  bool get hasNext => _audioPlayer.hasNext;
  bool get hasPrevious => _audioPlayer.hasPrevious;
  Duration? get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  int? get currentIndex => _audioPlayer.currentIndex;
}

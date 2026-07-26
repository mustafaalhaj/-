import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/audio_player_service.dart';

class AudioPlayerBar extends StatefulWidget {
  final AudioPlayerService audioService;
  final int? currentPlayingIndex;
  final bool isPlaying;

  const AudioPlayerBar({
    super.key,
    required this.audioService,
    required this.currentPlayingIndex,
    required this.isPlaying,
  });

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  // Streams are listened to here, only rebuilding this widget tree
  Stream<Duration?> get _positionStream => widget.audioService.positionStream;
  Stream<Duration?> get _durationStream => widget.audioService.durationStream;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A2E,
        ).withValues(alpha: 0.95), // Solid dark bg for performance
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.2,
            ), // Reduced opacity shadow
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Player Info Row
          StreamBuilder<Duration?>(
            stream: _positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;

              return StreamBuilder<Duration?>(
                stream: _durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;

                  return Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.graphic_eq,
                            color: Color(0xFFFFD700), // Gold
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'الآية ${(widget.currentPlayingIndex ?? 0) + 1}',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${_formatDuration(position)} / ${_formatDuration(duration)}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          activeTrackColor: const Color(0xFFFFD700), // Gold
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.2,
                          ),
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: min(
                            position.inSeconds.toDouble(),
                            duration.inSeconds.toDouble(),
                          ),
                          min: 0,
                          max: duration.inSeconds.toDouble() > 0
                              ? duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await widget.audioService.seek(position);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                ),
                onPressed: widget.audioService.seekToPrevious,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), // Gold
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    widget.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.black87,
                  ),
                  iconSize: 32,
                  onPressed: () async {
                    if (widget.isPlaying) {
                      await widget.audioService.pause();
                    } else {
                      await widget.audioService.play();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                onPressed: widget.audioService.seekToNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

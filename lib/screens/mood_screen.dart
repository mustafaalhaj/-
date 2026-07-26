import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood_data.dart';
import 'package:flutter/services.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  MoodData? _selectedMood;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: _selectedMood != null
          ? Color(_selectedMood!.color).withValues(alpha: 0.1)
          : colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "كيف تشعر اليوم؟",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Mood Grid
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: MoodRepository.moods.length,
              itemBuilder: (context, index) {
                final mood = MoodRepository.moods[index];
                final isSelected = _selectedMood?.label == mood.label;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(mood.color)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Color(mood.color).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(mood.color).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          mood.label,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _selectedMood == null
                  ? _buildEmptyState(colorScheme)
                  : _buildMoodContent(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.spa,
            size: 80,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "اختر حالتك الشعورية لنواسيك\nبآيات من الذكر الحكيم",
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: colorScheme.outline,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodContent(ColorScheme colorScheme) {
    return ListView.builder(
      key: ValueKey(_selectedMood?.label),
      padding: const EdgeInsets.all(16),
      itemCount: _selectedMood!.content.length,
      itemBuilder: (context, index) {
        final content = _selectedMood!.content[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(_selectedMood!.color).withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Color(_selectedMood!.color).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                content.type == 'quran' ? Icons.menu_book : Icons.format_quote,
                color: Color(_selectedMood!.color),
                size: 30,
              ),
              const SizedBox(height: 16),
              Text(
                content.text,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                content.source,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(_selectedMood!.color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

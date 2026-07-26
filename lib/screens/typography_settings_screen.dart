import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/typography_provider.dart';
import '../widgets/glass_background.dart';

class TypographySettingsScreen extends StatelessWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TypographyProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'استوديو الخطوط',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(
                    alpha: 0.6,
                  ), // Updated usage
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "بسم الله الرحمن الرحيم",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "هذا نص تجريبي لمعاينة الخط والحجم المختار. يمكنك تغيير الخط وحجم النص من الأسفل.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Font Family Selection
              Text(
                "نوع الخط",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.availableFonts.length,
                itemBuilder: (context, index) {
                  final font = provider.availableFonts[index];
                  final isSelected = provider.fontFamily == font;
                  return Card(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.1),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        font,
                        style: provider.getTextStyle(
                          baseStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : null,
                      onTap: () => provider.setFontFamily(font),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Font Size Slider
              Text(
                "حجم الخط",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "صغير",
                          style: GoogleFonts.cairo(color: Colors.white70),
                        ),
                        Text(
                          "كبير",
                          style: GoogleFonts.cairo(color: Colors.white70),
                        ),
                      ],
                    ),
                    Slider(
                      value: provider.valScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: "${(provider.valScale * 100).toInt()}%",
                      activeColor: colorScheme.primary,
                      onChanged: (val) => provider.setFontScale(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

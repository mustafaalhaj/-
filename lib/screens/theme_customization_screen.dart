import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/typography_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_background.dart';

class ThemeCustomizationScreen extends StatelessWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تخصيص المظهر',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            100,
            16,
            16,
          ), // Adjusted padding for AppBar
          child: Column(
            children: [
              // Preview Section
              _buildHashtagPreview(context, themeProvider),
              const SizedBox(height: 24),

              // Color Pickers
              _buildColorPickerTile(
                context,
                title: "لون العناصر الأساسي",
                currentColor: themeProvider.customPrimary,
                onColorChanged: (color) =>
                    themeProvider.updateCustomColors(primary: color),
              ),
              const SizedBox(height: 16),

              _buildColorPickerTile(
                context,
                title: "لون الخلفية",
                currentColor: themeProvider.customBackground,
                onColorChanged: (color) =>
                    themeProvider.updateCustomColors(background: color),
              ),
              const SizedBox(height: 16),

              _buildColorPickerTile(
                context,
                title: "لون التمييز (الأزرار/الأيقونات)",
                currentColor: themeProvider.customSecondary,
                onColorChanged: (color) =>
                    themeProvider.updateCustomColors(secondary: color),
              ),

              const SizedBox(height: 32),

              // Gradient Section
              _buildSectionTitle(context, "الخلفية والتدرجات"),
              SwitchListTile(
                title: Text(
                  "تفعيل التدرجات اللونية",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "قم بإيقافها لتحسين الأداء وتوفير البطارية",
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
                value: themeProvider.enableGradients,
                onChanged: (val) => themeProvider.toggleGradients(val),
                activeThumbColor: themeProvider.customPrimary,
              ),
              if (themeProvider.enableGradients) ...[
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGradientChip(
                        context,
                        themeProvider,
                        'sunset',
                        'غروب',
                        AppColors.sunsetGradient,
                      ),
                      _buildGradientChip(
                        context,
                        themeProvider,
                        'fajr',
                        'فجر',
                        AppColors.fajrGradient,
                      ),
                      _buildGradientChip(
                        context,
                        themeProvider,
                        'night',
                        'ليلي',
                        AppColors.nightGradient,
                      ),
                      _buildGradientChip(
                        context,
                        themeProvider,
                        'gold',
                        'ذهبي',
                        AppColors.goldGradient,
                      ),
                      _buildGradientChip(
                        context,
                        themeProvider,
                        'royal',
                        'ملكي',
                        AppColors.royalGradient,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Typography Section
              _buildSectionTitle(context, "الخطوط والنصوص"),
              const SizedBox(height: 16),

              _buildFontFamilySelector(context),
              const SizedBox(height: 16),

              _buildSliderTile(
                context,
                title: "حجم الخط",
                value: Provider.of<TypographyProvider>(context).valScale,
                min: 0.8,
                max: 1.4,
                onChanged: (val) => Provider.of<TypographyProvider>(
                  context,
                  listen: false,
                ).setFontScale(val),
              ),

              _buildSliderTile(
                context,
                title: "تباعد الأسطر",
                value: Provider.of<TypographyProvider>(context).lineHeight,
                min: 1.0,
                max: 2.2,
                onChanged: (val) => Provider.of<TypographyProvider>(
                  context,
                  listen: false,
                ).setLineHeight(val),
              ),

              const SizedBox(height: 32),

              // Warnings/Tips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'نصيحة: اختر لون خلفية داكن لتقليل استهلاك البطارية على شاشات OLED.',
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
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

  Widget _buildHashtagPreview(BuildContext context, ThemeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.customBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.menu, color: provider.customPrimary),
              Text(
                "أنا مسلم",
                style: GoogleFonts.getFont(
                  Provider.of<TypographyProvider>(context).fontFamily,
                  fontWeight: FontWeight.bold,
                  color: provider.customPrimary,
                  fontSize:
                      18 * Provider.of<TypographyProvider>(context).valScale,
                ),
              ),
              Icon(Icons.notifications, color: provider.customPrimary),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: provider.customPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_filled, color: provider.customSecondary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الفجر",
                      style: TextStyle(
                        color: provider.customPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "04:30 AM",
                      style: TextStyle(
                        color: provider.customPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.customPrimary,
              foregroundColor: provider.customBackground,
            ),
            child: const Text("تجربة الزر"),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerTile(
    BuildContext context, {
    required String title,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context, currentColor, onColorChanged),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: currentColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر لوناً'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('تم'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildFontFamilySelector(BuildContext context) {
    final fontProvider = Provider.of<TypographyProvider>(context);
    final fonts = [
      'Cairo',
      'Amiri',
      'Tajawal',
      'IBM Plex Sans Arabic',
      'Lateef',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("نوع الخط", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: fonts.contains(fontProvider.fontFamily)
                  ? fontProvider.fontFamily
                  : 'Cairo',
              isExpanded: true,
              items: fonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font, style: GoogleFonts.getFont(font)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) fontProvider.setFontFamily(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildGradientChip(
    BuildContext context,
    ThemeProvider provider,
    String key,
    String label,
    LinearGradient gradient,
  ) {
    final isSelected = provider.selectedGradient == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => provider.setGradientPreset(key),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, color: Colors.white, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

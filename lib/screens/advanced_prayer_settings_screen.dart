import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import '../providers/prayer_times_provider.dart';
import '../widgets/glass_background.dart';

class AdvancedPrayerSettingsScreen extends StatelessWidget {
  const AdvancedPrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إعدادات المواقيت المتقدمة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: GlassBackground(
        child: Consumer<PrayerTimesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                100,
                16,
                16,
              ), // Adjusted for AppBar
              children: [
                _buildSectionTitle(context, 'طريقة الحساب'),

                SwitchListTile(
                  title: const Text('تحديد تلقائي (PROMET MAKER)'),
                  subtitle: const Text(
                    'اختيار الطريقة والمذهب حسب الدولة تلقائياً',
                  ),
                  value: provider.autoDetect,
                  onChanged: (val) {
                    provider.updateSettings(autoDetect: val);
                  },
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IgnorePointer(
                      ignoring: provider.autoDetect,
                      child: Opacity(
                        opacity: provider.autoDetect ? 0.5 : 1.0,
                        child: _buildMethodDropdown(context, provider),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle(context, 'المذهب'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IgnorePointer(
                      ignoring: provider.autoDetect,
                      child: Opacity(
                        opacity: provider.autoDetect ? 0.5 : 1.0,
                        child: DropdownButton<Madhab>(
                          isExpanded: true,
                          value: provider.madhab,
                          underline: Container(),
                          onChanged: (val) {
                            if (val != null) {
                              provider.updateSettings(madhab: val);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Madhab.shafi,
                              child: Text('شافعي (ومالكي، حنبلي)'),
                            ),
                            DropdownMenuItem(
                              value: Madhab.hanafi,
                              child: Text('حنفي'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionTitle(context, 'تعديل الأوقات (دقائق)'),
                const Text('إضافة أو طرح دقائق من وقت الأذان يدوياً'),
                const SizedBox(height: 10),

                _buildOffsetRow(context, 'الفجر', Prayer.fajr, provider),
                _buildOffsetRow(context, 'الشروق', Prayer.sunrise, provider),
                _buildOffsetRow(context, 'الظهر', Prayer.dhuhr, provider),
                _buildOffsetRow(context, 'العصر', Prayer.asr, provider),
                _buildOffsetRow(context, 'المغرب', Prayer.maghrib, provider),
                _buildOffsetRow(context, 'العشاء', Prayer.isha, provider),

                const SizedBox(height: 20),
                _buildSectionTitle(context, 'المناطق ذات خطوط العرض العليا'),
                SwitchListTile(
                  title: const Text('تفعيل حساب المناطق الشمالية'),
                  subtitle: const Text('يُستخدم عندما لا يغيب الشفق (تقديراً)'),
                  value: provider.highLatitudeAdjustment,
                  onChanged: (val) {
                    provider.updateSettings(highLatitude: val);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildOffsetRow(
    BuildContext context,
    String label,
    Prayer prayer,
    PrayerTimesProvider provider,
  ) {
    int currentOffset = provider.offsets[prayer] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                Map<Prayer, int> newOffsets = Map.from(provider.offsets);
                newOffsets[prayer] = currentOffset - 1;
                provider.updateSettings(offsets: newOffsets);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$currentOffset',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                Map<Prayer, int> newOffsets = Map.from(provider.offsets);
                newOffsets[prayer] = currentOffset + 1;
                provider.updateSettings(offsets: newOffsets);
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDropdown(
    BuildContext context,
    PrayerTimesProvider provider,
  ) {
    return DropdownButton<CalculationMethod>(
      isExpanded: true,
      value: provider.method,
      underline: Container(),
      onChanged: (val) {
        if (val != null) {
          provider.updateSettings(method: val);
        }
      },
      items: const [
        DropdownMenuItem(
          value: CalculationMethod.muslim_world_league,
          child: Text('رابطة العالم الإسلامي'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.egyptian,
          child: Text('الهيئة المصرية العامة للمساحة'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.karachi,
          child: Text('جامعة العلوم الإسلامية بكراتشي'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.umm_al_qura,
          child: Text('أم القرى (السعودية)'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.dubai,
          child: Text('دائرة الشؤون الإسلامية والعمل الخيري (دبي)'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.qatar,
          child: Text('وزارة الأوقاف والشؤون الإسلامية (قطر)'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.kuwait,
          child: Text('وزارة الأوقاف والشؤون الإسلامية (الكويت)'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.singapore,
          child: Text('المجلس الإسلامي السنغافوري'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.turkey,
          child: Text('رئاسة الشؤون الدينية (تركيا)'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.tehran,
          child: Text('معهد الجيوفيزياء بجامعة طهران'),
        ),
        DropdownMenuItem(
          value: CalculationMethod.north_america,
          child: Text('الجمعية الإسلامية لأمريكا الشمالية'),
        ),
      ],
    );
  }
}

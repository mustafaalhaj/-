import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_preferences_provider.dart';
import '../services/local_reminder_scheduler.dart';
import '../widgets/glass_background.dart';
import '../widgets/islamic_loader.dart';

/// شاشة تخصيص وتفضيلات الإشعارات للمستخدم
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'إعدادات الإشعارات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: Consumer<NotificationPreferencesProvider>(
          builder: (context, prefs, child) {
            if (prefs.isLoading) {
              return const Center(child: IslamicLoader(size: 50));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- القسم الأول: الأذان ومواقيت الصلاة ---
                  _buildSectionHeader('تنبيهات الأذان ومواقيت الصلاة'),
                  _buildGlassCard(
                    children: [
                      _buildSwitchTile(
                        title: 'أذان صلاة الفجر',
                        subtitle: 'رفع الصوت والتنبيه بوقت الفجر',
                        value: prefs.fajrAdhan,
                        onChanged: (val) {
                          prefs.setPrayerAdhan('fajr', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'أذان صلاة الظهر',
                        subtitle: 'رفع الصوت والتنبيه بوقت الظهر',
                        value: prefs.dhuhrAdhan,
                        onChanged: (val) {
                          prefs.setPrayerAdhan('dhuhr', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'أذان صلاة العصر',
                        subtitle: 'رفع الصوت والتنبيه بوقت العصر',
                        value: prefs.asrAdhan,
                        onChanged: (val) {
                          prefs.setPrayerAdhan('asr', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'أذان صلاة المغرب',
                        subtitle: 'رفع الصوت والتنبيه بوقت المغرب',
                        value: prefs.maghribAdhan,
                        onChanged: (val) {
                          prefs.setPrayerAdhan('maghrib', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'أذان صلاة العشاء',
                        subtitle: 'رفع الصوت والتنبيه بوقت العشاء',
                        value: prefs.ishaAdhan,
                        onChanged: (val) {
                          prefs.setPrayerAdhan('isha', val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- القسم الثاني: الأذكار والتنبيهات المحلية ---
                  _buildSectionHeader('الأذكار والتنبيهات الإيمانية'),
                  _buildGlassCard(
                    children: [
                      _buildTimePickerTile(
                        context: context,
                        title: 'أذكار الصباح ☀️',
                        subtitle:
                            'وقت التنبيه: ${_formatTime(prefs.morningTime)}',
                        value: prefs.morningAdhkar,
                        time: prefs.morningTime,
                        onChanged: (val) async {
                          await prefs.setMorningAdhkar(val);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                        onTimeSelected: (newTime) async {
                          await prefs.setMorningAdhkar(true, time: newTime);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildTimePickerTile(
                        context: context,
                        title: 'أذكار المساء 🌙',
                        subtitle:
                            'وقت التنبيه: ${_formatTime(prefs.eveningTime)}',
                        value: prefs.eveningAdhkar,
                        time: prefs.eveningTime,
                        onChanged: (val) async {
                          await prefs.setEveningAdhkar(val);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                        onTimeSelected: (newTime) async {
                          await prefs.setEveningAdhkar(true, time: newTime);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'سورة الكهف يوم الجمعة 📖',
                        subtitle: 'تذكير أسبوعي صباح كل يوم جمعة الساعة 9:00 ص',
                        value: prefs.fridayKahf,
                        onChanged: (val) async {
                          await prefs.setFridayKahf(val);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'قيام الليل 🌌',
                        subtitle: 'تذكير بالثلث الأخير من الليل الساعة 02:30 ص',
                        value: prefs.qiyamLayl,
                        onChanged: (val) async {
                          await prefs.setQiyamLayl(val);
                          await LocalReminderScheduler().syncAllReminders(
                            prefs,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- القسم الثالث: الإشعارات السحابية اليومية (FCM Topics) ---
                  _buildSectionHeader('الإشعارات السحابية اليومية'),
                  _buildGlassCard(
                    children: [
                      _buildSwitchTile(
                        title: 'آية اليوم 📖',
                        subtitle:
                            'استلام آية قرآنية تدبرية يومية مع التفسير المختصر',
                        value: prefs.dailyQuranTopic,
                        onChanged: (val) {
                          prefs.setTopicSubscription('daily_quran', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'حديث اليوم 📜',
                        subtitle: 'استلام حديث نبوي صحيح يومياً مع المعنى',
                        value: prefs.dailyHadithTopic,
                        onChanged: (val) {
                          prefs.setTopicSubscription('daily_hadith', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'ذكر اليوم 📿',
                        subtitle: 'استلام أذكار وأدعية مأثورة متجددة',
                        value: prefs.dailyDhikrTopic,
                        onChanged: (val) {
                          prefs.setTopicSubscription('daily_dhikr', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        title: 'إعلانات وأخبار التطبيق 📢',
                        subtitle: 'استلام التحديثات والمناسبات الإسلامية الهامة',
                        value: prefs.announcementsTopic,
                        onChanged: (val) {
                          prefs.setTopicSubscription('announcements', val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // زر تجربة الإشعار الفوري
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_active),
                      label: Text(
                        'تجربة تذكير أذكار الصباح محلياً',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        await LocalReminderScheduler().scheduleDailyReminder(
                          id: 9999,
                          title: 'تجربة الإشعار المحلي ☀️',
                          body: 'هذا إشعار تجريبي للتأكد من عمل المحرك المحلي',
                          time: TimeOfDay.now(),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال إشعار تجريبي محلي'),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      value: value,
      activeThumbColor: const Color(0xFFD4AF37), // Gold
      onChanged: onChanged,
    );
  }

  Widget _buildTimePickerTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required TimeOfDay time,
    required ValueChanged<bool> onChanged,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.access_time, color: Color(0xFFD4AF37)),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) {
                onTimeSelected(picked);
              }
            },
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFD4AF37),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }
}

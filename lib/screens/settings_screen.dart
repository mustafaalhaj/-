import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/typography_provider.dart';
import '../providers/theme_provider.dart';
import 'advanced_prayer_settings_screen.dart';
import 'theme_customization_screen.dart';
import '../widgets/glass_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final typographyProvider = Provider.of<TypographyProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Important for GlassBackground
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "الإعدادات",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.settings,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),

            // Settings Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Selection
                    _buildSectionTitle("المظهر", Icons.palette),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildActionTile(
                          title: "تخصيص الألوان والخطوط",
                          subtitle: "عدل ألوان الأزرار والأيقونات كما تحب",
                          icon: Icons.color_lens,
                          iconColor: themeProvider.customPrimary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ThemeCustomizationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Font Size
                    _buildSectionTitle("المظهر", Icons.text_fields),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildSliderTile(
                          title: "حجم الخط",
                          subtitle: _getFontSizeLabel(
                            typographyProvider.valScale,
                          ),
                          icon: Icons.text_fields,
                          iconColor: Colors.blue,
                          value: typographyProvider.valScale,
                          min: 0.8,
                          max: 1.4,
                          onChanged: (val) {
                            typographyProvider.setFontScale(val);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notifications
                    _buildSectionTitle(
                      "الإعدادات والمواقيت",
                      Icons.settings_suggest,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildSwitchTile(
                          title: "تنبيهات الصلاة",
                          subtitle: "تلقي إشعارات عند دخول وقت الصلاة",
                          icon: Icons.notifications_active,
                          iconColor: Colors.green,
                          value: _notificationsEnabled,
                          onChanged: _saveNotifications,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "تخصيص جميع الإشعارات والأذكار",
                          subtitle:
                              "تغيير مواعيد الأذكار والأذان والإشعارات اليومية",
                          icon: Icons.notifications_paused_rounded,
                          iconColor: const Color(0xFFD4AF37),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/notification-settings',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "لوحة إرسال الإشعارات (للأدمن)",
                          subtitle: "صياغة وتجهيز إشعارات الفايربيس",
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: Colors.amber,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-notifications',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "إعدادات المواقيت المتقدمة",
                          subtitle: "تعديل طريقة الحساب والمذهب والموقع",
                          icon: Icons.access_time_filled,
                          iconColor: Colors.deepPurple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdvancedPrayerSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "تخصيص الواجهة",
                          subtitle: "ترتيب وإظهار عناصر الشاشة الرئيسية",
                          icon: Icons.dashboard_customize_rounded,
                          iconColor: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, '/home-layout-editor');
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "استوديو الخطوط",
                          subtitle: "تغيير نوع وحجم الخط",
                          icon: Icons.text_fields_rounded,
                          iconColor: Colors.blueAccent,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/typography-settings',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // About
                    _buildSectionTitle("حول التطبيق", Icons.info),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildInfoTile(
                          title: "اسم التطبيق",
                          value: "أنا مسلم",
                          icon: Icons.mosque,
                          iconColor: Colors.teal,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          title: "الإصدار",
                          value: '1.0.7',
                          icon: Icons.new_releases,
                          iconColor: Colors.purple,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "المطور",
                          subtitle: "Al Haj Mustafa - تابعني على إنستغرام",
                          icon: Icons.person,
                          iconColor: Colors.indigo,
                          onTap: () async {
                            const username = "mustafa.alhaj.mustafa";
                            final nativeUrl = Uri.parse(
                              "instagram://user?username=$username",
                            );
                            final webUrl = Uri.parse(
                              "https://www.instagram.com/$username/",
                            );

                            try {
                              if (await canLaunchUrl(nativeUrl)) {
                                await launchUrl(nativeUrl);
                              } else {
                                await launchUrl(
                                  webUrl,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'لا يمكن فتح التطبيق أو المتصفح',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Support
                    _buildSectionTitle("الدعم", Icons.support),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildActionTile(
                          title: "تقييم التطبيق",
                          subtitle: "ساعدنا بتقييم التطبيق على المتجر",
                          icon: Icons.star,
                          iconColor: Colors.amber,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('شكراً لك! ❤️')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          title: "مشاركة التطبيق",
                          subtitle: "شارك التطبيق مع أصدقائك",
                          icon: Icons.share,
                          iconColor: Colors.blue,
                          onTap: () {
                            const String appLink =
                                'https://com-alhajmustafaana-anamuslim.ar.uptodown.com/android';
                            Share.share(
                              'حمل تطبيق "أنا مسلم" الآن! تطبيق إسلامي شامل فيه القرآن، الأذكار، القبلة والمزيد.\n\n$appLink',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red.withValues(alpha: 0.5),
                            size: 24,
                          ),
                          Text(
                            "صنع بحب ❤️",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 6,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getFontSizeLabel(double size) {
    if (size < 0.95) return "صغير";
    if (size < 1.15) return "عادي";
    if (size < 1.35) return "كبير";
    return "كبير جداً";
  }
}

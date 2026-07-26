import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/glass_background.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------- FEATURES LIST ----------
    final features = [
      {
        'title': 'التقويم الهجري',
        'subtitle': 'المناسبات والأيام المباركة',
        'icon': Icons.calendar_month_outlined,
        'route': '/hijri-calendar',
        'isLive': false,
      },
      {
        'title': 'الإعدادات',
        'subtitle': 'عام، الإشعارات، الحساب',
        'icon': Icons.settings_outlined,
        'route': '/settings',
        'isLive': false,
      },
      {
        'title': 'البث المباشر',
        'subtitle': 'مواقيت الصلاة، تلاوات، أحداث',
        'icon': Icons.play_arrow_outlined,
        'route': '/live',
        'isLive': true,
      },
      {
        'title': 'حول التطبيق',
        'subtitle': 'الإصدار، المطور، تواصل معنا',
        'icon': Icons.info_outline,
        'route': '/about',
        'isLive': false,
      },
      {
        'title': 'سياسة الخصوصية',
        'subtitle': 'حماية البيانات والأذونات',
        'icon': Icons.privacy_tip_outlined,
        'route': '/privacy-policy',
        'isLive': false,
      },
      // --- Other features kept for functionality but styled consistently ---
      {
        'title': 'القبلة',
        'subtitle': 'اتجاه القبلة بالبوصلة',
        'icon': Icons.explore_outlined,
        'route': '/qibla',
        'isLive': false,
      },
      {
        'title': 'المساعد الذكي',
        'subtitle': 'اسأل في الدين والقرآن',
        'icon': Icons.smart_toy_outlined,
        'route': '/ai-chat',
        'isLive': false,
      },
      {
        'title': 'حالتي',
        'subtitle': 'آيات وأدعية حسب حالتك',
        'icon': Icons.mood_outlined,
        'route': '/mood',
        'isLive': false,
      },
      {
        'title': 'تتبع الصيام',
        'subtitle': 'الإثنين والخميس والأيام البيض',
        'icon': Icons.nights_stay_outlined,
        'route': '/fasting',
        'isLive': false,
      },
      {
        'title': 'التسبيح',
        'subtitle': 'عداد التسبيح والذكر',
        'icon': Icons.fingerprint,
        'route': '/tasbih',
        'isLive': false,
      },
      {
        'title': 'أسماء الله الحسنى',
        'subtitle': '٩٩ اسماً لله تعالى',
        'icon': Icons.stars_outlined,
        'route': '/asmaul-husna',
        'isLive': false,
      },
      {
        'title': 'الأدعية',
        'subtitle': 'أدعية مأثورة من السنة',
        'icon': Icons.menu_book_outlined,
        'route': '/duas',
        'isLive': false,
      },
    ];

    // ---------- MAIN SCAFFOLD ----------
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GlassBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- APP BAR ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Text(
                    'المزيد',
                    style: GoogleFonts.inter(
                      // Or Cairo/Inter
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),

              // --- LIST CONTENT ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final feature = features[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGlassCard(context, feature),
                    );
                  }, childCount: features.length),
                ),
              ),

              // --- FOOTER SPACE ---
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // GLASS CARD COMPONENT
  // --------------------------------------------------------------
  Widget _buildGlassCard(BuildContext context, Map<String, dynamic> feature) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1), // Translucent white
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2), // Thin white border
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (feature['isLive'] == true || feature['route'] != null) {
              if (feature['route'] != null) {
                Navigator.pushNamed(context, feature['route']);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('قريباً..', style: GoogleFonts.cairo()),
                  backgroundColor: const Color(0xFF1E2A5A),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // ICON CONTAINER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            feature['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (feature['isLive'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "LIVE",
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['subtitle'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // ARROW ICON
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

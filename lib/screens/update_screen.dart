import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_background.dart';

class UpdateScreen extends StatelessWidget {
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;
  final bool isForceUpdate;

  const UpdateScreen({
    super.key,
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.isForceUpdate,
  });

  Future<void> _launchDownloadUrl() async {
    final Uri url = Uri.parse(downloadUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent back button on force update using PopScope
    return PopScope(
      canPop: !isForceUpdate,
      child: Scaffold(
        body: GlassBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rocket/Update Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 48,
                          color: Color(0xFF00BFA5), // Teal Accent
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'تحديث جديد متاح!',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        isForceUpdate
                            ? 'يرجى تحديث التطبيق للمتابعة والحصول على أحدث المميزات والتحسينات.\nهذا التحديث إجباري.'
                            : 'تتوفر نسخة جديدة من التطبيق مع تحسينات في الأداء ومميزات جديدة.',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Version Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currentVersion → $latestVersion',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _launchDownloadUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'تحديث الآن 🚀',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (!isForceUpdate) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'لاحقاً',
                            style: GoogleFonts.cairo(color: Colors.white54),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

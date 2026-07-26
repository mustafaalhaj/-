import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'سياسة الخصوصية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('مقدمة'),
              _buildParagraph(
                'نحن في تطبيق "أنا مسلم" نولي اهتماماً كبيراً لخصوصية مستخدمينا. '
                'تهدف سياسة الخصوصية هذه إلى توضيح نوع المعلومات التي قد نجمعها، '
                'وكيفية استخدامها، وكيفية حمايتها.',
              ),
              const Divider(height: 32),

              _buildSectionTitle('البيانات التي نجمعها'),
              _buildParagraph(
                'تطبيق "أنا مسلم" مصمم ليكون آمناً ويحترم خصوصيتك. '
                'نحن لا نجمع أي بيانات شخصية (مثل الاسم، رقم الهاتف، أو البريد الإلكتروني) '
                'على خوادمنا. جميع بياناتك تبقى محفوظة محلياً على جهازك.',
              ),
              const SizedBox(height: 16),
              _buildSubTitle('1. بيانات الموقع الجغرافي (Location)'),
              _buildParagraph(
                'يطلب التطبيق إذن الوصول إلى الموقع الجغرافي (GPS) لغرض واحد فقط وهو: '
                'حساب مواقيت الصلاة بدقة وتحديد اتجاه القبلة حسب موقعك الحالي. '
                'يتم استخدام هذه الإحداثيات محلياً داخل التطبيق ولا يتم إرسالها أو تخزينها على أي خوادم خارجية.',
              ),
              const SizedBox(height: 16),
              _buildSubTitle('2. إذن الكاميرا (Camera)'),
              _buildParagraph(
                'قد يطلب التطبيق إذن الوصول إلى الكاميرا لاستخدام ميزة "القبلة بالواقع المعزز" (AR Qibla). '
                'تُستخدم الكاميرا فقط لعرض الاتجاهات على الشاشة في الوقت الفعلي، ولا يتم التقاط أو تخزين أي صور أو فيديوهات.',
              ),
              const SizedBox(height: 16),
              _buildSubTitle('3. الإشعارات (Notifications)'),
              _buildParagraph(
                'نستخدم الإشعارات المحلية لإرسال تنبيهات أوقات الصلاة والأذكار. '
                'قد نستخدم أيضاً إشعارات سحابية (Firebase Cloud Messaging) لإرسال تحديثات مهمة أو مناسبات دينية، '
                'دون ربطها بأي هوية شخصية للمستخدم.',
              ),

              const Divider(height: 32),

              _buildSectionTitle('كيف نستخدم المعلومات؟'),
              _buildParagraph(
                '• لحساب مواقيت الصلاة بدقة لموقعك.\n'
                '• لتحديد اتجاه القبلة من مكانك.\n'
                '• لحفظ تقدمك في قراءة القرآن والأذكار (محلياً على الجهاز).\n'
                '• لتحسين تجربة المستخدم داخل التطبيق.',
              ),

              const Divider(height: 32),

              _buildSectionTitle('مشاركة البيانات'),
              _buildParagraph(
                'نحن لا نشارك أي بيانات شخصية مع أي أطراف ثالثة. '
                'التطبيق يعمل بشكل مستقل ويحترم سرية بياناتك.',
              ),

              const Divider(height: 32),

              _buildSectionTitle('اتصل بنا'),
              _buildParagraph(
                'إذا كان لديك أي أسئلة أو استفسارات حول سياسة الخصوصية هذه، '
                'يمكنك التواصل معنا عبر البريد الإلكتروني:',
              ),
              InkWell(
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'mustafa963alhaj@gmail.com',
                    query: 'subject=استفسار عن سياسة الخصوصية',
                  );
                  try {
                    await launchUrl(emailUri);
                  } catch (e) {
                    debugPrint('Error launching email: $e');
                  }
                },
                child: Text(
                  'mustafa963alhaj@gmail.com',
                  style: GoogleFonts.inter(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF009688), // Teal color
        ),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.6,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

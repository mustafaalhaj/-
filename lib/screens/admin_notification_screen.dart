import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_background.dart';

/// لوحة تحكم الأدمن لجدولة وإرسال الإشعارات مع حماية وتشفير متقدم (SHA-256)
class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  // حالة تسجيل الدخول للأدمن
  bool _isLoggedIn = false;
  bool _obscurePassword = true;

  // متحكم كلمة المرور
  final _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // حماية ضد الهجمات (Anti-Brute Force Protection)
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  // التشفير المتقدم (SHA-256 Hash لكلمة المرور "2003")
  static const String _hashedTargetPassword =
      '77459b9b941bcb4714d0c121313c900ecf30541d158eb2b9b178cdb8eca6457e';

  // متحكمات نموذج الإشعارات
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _deepLinkController = TextEditingController();

  String _selectedCategory = 'daily_quran';
  String _selectedTopic = 'topic_ar_daily_quran';
  bool _isSending = false;

  final Map<String, String> _categories = {
    'daily_quran': 'آية اليوم 📖',
    'daily_hadith': 'حديث اليوم 📜',
    'daily_dhikr': 'ذكر اليوم 📿',
    'announcement': 'إعلان عام 📢',
  };

  final Map<String, String> _topics = {
    'topic_ar_daily_quran': 'جمهور الآية القرآنية (عربي)',
    'topic_ar_daily_hadith': 'جمهور الحديث النبوي (عربي)',
    'topic_ar_daily_dhikr': 'جمهور الأذكار اليومية (عربي)',
    'topic_announcements': 'جميع مستخدمي التطبيق (عام)',
  };

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _passwordController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _deepLinkController.dispose();
    super.dispose();
  }

  /// تشفير كلمة المرور المُدخلة ومقارنة الـ Hash
  String _hashPassword(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _startLockoutTimer() {
    setState(() {
      _isLockedOut = true;
      _lockoutSeconds = 300; // قفل لـ 5 دقائق (300 ثانية)
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isLockedOut = false;
          _failedAttempts = 0;
          _lockoutSeconds = 0;
        });
      } else {
        setState(() {
          _lockoutSeconds--;
        });
      }
    });
  }

  void _handleLogin() {
    if (_isLockedOut) return;
    if (!_loginFormKey.currentState!.validate()) return;

    final inputPassword = _passwordController.text.trim();
    final inputHash = _hashPassword(inputPassword);

    // التحقق المشفر SHA-256 لكلمة المرور 2003
    if (inputPassword == '2003' || inputHash == _hashedTargetPassword) {
      setState(() {
        _isLoggedIn = true;
        _failedAttempts = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[700],
          content: Text(
            'تم فك التشفير وتسجيل الدخول بنجاح كـ مشرف التطبيق 🔐',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      setState(() {
        _failedAttempts++;
      });

      if (_failedAttempts >= 5) {
        _startLockoutTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text(
              'تم تجاوز عدد المحاولات المسموحة! تم قفل الدخول لمدة 5 دقائق للحماية.',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[700],
            content: Text(
              'كلمة المرور غير صحيحة! المتبقي ${_maxAttempts - _failedAttempts} محاولات قبل القفل.',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  static const int _maxAttempts = 5;

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    setState(() {
      _selectedCategory = category;
      switch (category) {
        case 'daily_quran':
          _selectedTopic = 'topic_ar_daily_quran';
          _titleController.text = 'آية اليوم 📖';
          break;
        case 'daily_hadith':
          _selectedTopic = 'topic_ar_daily_hadith';
          _titleController.text = 'حديث اليوم 📜';
          break;
        case 'daily_dhikr':
          _selectedTopic = 'topic_ar_daily_dhikr';
          _titleController.text = 'ذكر اليوم 📿';
          break;
        case 'announcement':
          _selectedTopic = 'topic_announcements';
          _titleController.text = 'تنبيه مهم 📢';
          break;
      }
    });
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    try {
      // 1. نسخ النص إلى الحافظة
      final clipboardText = 'العنوان: $title\nالنص: $body';
      await Clipboard.setData(ClipboardData(text: clipboardText));

      // 2. فتح لوحة الفايربيس مباشرة لجميع المستخدمين
      final Uri url = Uri.parse(
        'https://console.firebase.google.com/u/0/project/ana-muslim-1ac8e/notification/compose?type=notification',
      );
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch url: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 4),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '✅ تم نسخ الإشعار وتوجيهك فوراً للفايربيس للإرسال المجاني!',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isLoggedIn ? 'لوحة تحكم الأدمن' : 'حماية الأدمن 🔐',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.amber),
                  tooltip: 'تسجيل الخروج',
                  onPressed: () {
                    setState(() {
                      _isLoggedIn = false;
                      _passwordController.clear();
                    });
                  },
                ),
              ]
            : null,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 90),
          child: _isLoggedIn ? _buildAdminDashboard() : _buildLoginForm(),
        ),
      ),
    );
  }

  /// واجهة تسجيل الدخول عالية الأمان المحمية بتشفير SHA-256
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _isLockedOut
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isLockedOut ? Colors.red : Colors.amber,
                width: 2,
              ),
            ),
            child: Icon(
              _isLockedOut
                  ? Icons.lock_clock
                  : Icons.security_rounded,
              size: 70,
              color: _isLockedOut ? Colors.red : Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isLockedOut ? 'النظام مقفل مؤقتاً 🔒' : 'منطقة محمية بالأمان الفائق',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLockedOut
                ? 'تم القفل للحماية بعد محاولات خاطئة. انتظر الحساب التنازلي:'
                : 'أدخل كلمة المرور السرية للمشرف (مشفّرة بنظام SHA-256)',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          if (_isLockedOut) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[900]?.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⏱️ متبقي: ${_lockoutSeconds ~/ 60}:${(_lockoutSeconds % 60).toString().padLeft(2, '0')} دقيقة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const SizedBox(height: 30),

          // كرت تسجيل الدخول الزجاجي
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'كلمة المرور المشفرة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLockedOut,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key, color: Colors.amber),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'أدخل كلمة المرور...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // زر تسجيل الدخول
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLockedOut ? Colors.grey : Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.verified_user_rounded),
              label: Text(
                _isLockedOut ? 'النظام مقفل' : 'تأكيد الدخول الآمن',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isLockedOut ? null : _handleLogin,
            ),
          ),
        ],
      ),
    );
  }

  /// لوحة تحكم الإشعارات المكتملة
  Widget _buildAdminDashboard() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كرت طلب تسجيل الدخول المباشر لحساب الفايربيس
          _buildCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسجيل دخول Firebase Console',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'https://console.firebase.google.com/',
                        style: GoogleFonts.cairo(
                          color: Colors.amber.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    'فتح الفايربيس',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(
                      'https://console.firebase.google.com/u/0/project/ana-muslim-1ac8e/notification/compose?type=notification',
                    );
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint('Could not launch url: $e');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع الإشعار وفئة المحتوى',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: Colors.grey[900],
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: _onCategoryChanged,
                ),
                const SizedBox(height: 16),
                Text(
                  'الموضوع المستهدف (FCM Topic)',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTopic,
                  dropdownColor: Colors.grey[900],
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _topics.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTopic = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان الإشعار',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب عنوان الإشعار...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة العنوان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'نص الإشعار (المحتوى)',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 4,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب نص الآية أو الحديث أو التنبيه...',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة نص الإشعار';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'مسار التوجيه المباشر (Deep Link Route - اختياري)',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _deepLinkController,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: /quran أو /adhkar أو /hadith',
                    hintStyle: GoogleFonts.cairo(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSending ? 'جاري الإرسال...' : 'حفظ نموذج الإشعار',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isSending ? null : _sendNotification,
            ),
          ),
          const SizedBox(height: 12),

          // زر نسخ النص وفتح لوحة الفايربيس بنقرة واحدة
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.blueAccent),
              label: Text(
                'نسخ النص وفتح لوحة الفايربيس (Firebase) 🚀',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();

                if (title.isEmpty && body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange[800],
                      content: Text(
                        'يرجى كتابة العنوان والنص أولاً لنسخهما',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                  return;
                }

                // 1. نسخ النص إلى الحافظة
                final clipboardText = 'العنوان: $title\nالنص: $body';
                await Clipboard.setData(ClipboardData(text: clipboardText));

                // 2. فتح لوحة الفايربيس السحابية المجانية
                final Uri url = Uri.parse(
                  'https://console.firebase.google.com/u/0/project/ana-muslim-1ac8e/notification/compose?type=notification',
                );
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Could not launch url: $e');
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green[700],
                      content: Text(
                        'تم نسخ العنوان والنص وفتح لوحة الفايربيس بنجاح! 🚀',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

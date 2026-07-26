import 'package:flutter/material.dart';

/// خلفية زجاجية متدرجة تملأ الشاشة كاملاً
/// تستخدم Positioned.fill لضمان التغطية الكاملة على iOS/Android/Web
class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GlassBackground({super.key, required this.child, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      // ✅ Material يمنح الخلفية الداكنة الأساسية ويضمن الرسم الصحيح على iOS
      color: const Color(0xFF1B1537),
      child: Stack(
        // ✅ لا نستخدم StackFit.expand - نستخدم Positioned.fill بدلاً منه
        children: [
          // 1. الخلفية المتدرجة - Positioned.fill يضمن ملء المساحة كاملاً دائماً
          Positioned.fill(
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2B1F4D), // Rich Deep Purple (Top-Left)
                      Color(0xFF2C3E6B), // Purple-Blue (Middle)
                      Color(0xFF1A4A5C), // Dark Blue-Teal (Bottom-Right)
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. توهج ضوئي زخرفي (أعلى اليمين)
          Positioned(
            top: -150,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. نجمة زخرفية كبيرة
          Positioned(
            top: -120,
            right: -120,
            child: IgnorePointer(
              child: Icon(
                Icons.star_rounded,
                size: 450,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // 4. شبكة زخرفية (أسفل اليسار)
          Positioned(
            bottom: -100,
            left: -100,
            child: IgnorePointer(
              child: Icon(
                Icons.grid_4x4_rounded,
                size: 400,
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          ),

          // 5. محتوى الشاشة فوق الخلفية
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GlassBackground({super.key, required this.child, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // ✅ fit: StackFit.expand يجبر كل أبناء الـ Stack على ملء المساحة الكاملة
      fit: StackFit.expand,
      children: [
        // 1. Static Background (Cached) - يجب أن يملأ الشاشة كاملاً
        RepaintBoundary(
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Base Gradient - ✅ SizedBox.expand يضمن ملء الشاشة كاملاً
                Container(
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

                // 2. Large Soft Star / Radial Glow (Top Center)
                Positioned(
                  top: -150,
                  right: -100,
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

                // 3. Huge Star Outline (Decorative)
                Positioned(
                  top: -120,
                  right: -120,
                  child: Icon(
                    Icons.star_rounded,
                    size: 450,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),

                // 4. Subtle Grid Pattern (Bottom Left)
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Icon(
                    Icons.grid_4x4_rounded,
                    size: 400,
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Child Content
        child,
      ],
    );
  }
}

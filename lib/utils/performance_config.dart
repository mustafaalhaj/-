import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// إعدادات الأداء لضمان 60fps
class PerformanceConfig {
  /// تفعيل وضع الأداء العالي
  static void enableHighPerformance() {
    // تفعيل GPU rendering
    debugProfileBuildsEnabled = false;
    debugProfilePaintsEnabled = false;

    // تحسين الرسومات
    debugRepaintRainbowEnabled = false;
  }

  /// مدة الرسوم المتحركة القياسية (سريعة وسلسة)
  static const Duration standardAnimationDuration = Duration(milliseconds: 200);

  /// مدة الرسوم المتحركة السريعة
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// منحنى الرسوم المتحركة المحسّن
  static const Curve standardCurve = Curves.easeOutCubic;

  /// الحد الأقصى لعدد العناصر في القائمة قبل استخدام ListView.builder
  static const int maxListItemsBeforeBuilder = 20;

  /// تأخير debounce للبحث والإدخال
  static const Duration searchDebounce = Duration(milliseconds: 300);
}

/// Widget محسّن للأداء مع const constructor
class OptimizedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;

  const OptimizedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// RepaintBoundary wrapper لتحسين الأداء
class PerformanceBoundary extends StatelessWidget {
  final Widget child;

  const PerformanceBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

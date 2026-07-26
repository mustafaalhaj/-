import 'package:flutter/material.dart';
import 'dart:math' as math;

class IslamicLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const IslamicLoader({super.key, this.size = 50.0, this.color});

  @override
  State<IslamicLoader> createState() => _IslamicLoaderState();
}

class _IslamicLoaderState extends State<IslamicLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Loop forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).primaryColor;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: _CrescentPainter(color: themeColor)),
        ),
      ),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  final Color color;

  _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw Crescent (Moon)
    final path = Path();
    // Outer arc
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      0.5, // Start angle
      5.0, // Sweep angle (not full circle)
    );
    canvas.drawPath(path, paint);

    // Draw Star (Small Dot orbiting)
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Position star near the opening of the crescent
    // Simulating a star orbiting
    canvas.drawCircle(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.4),
      radius * 0.15, // Star size
      starPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

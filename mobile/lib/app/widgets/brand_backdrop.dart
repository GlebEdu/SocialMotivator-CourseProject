import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';

class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({
    required this.child,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: HabitBetTheme.scaffoldDecoration(),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: HabitBetTheme.canvas),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 270,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFF112732),
                    Color(0xFF173642),
                    Color(0x00173642),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _DustPainter())),
          ),
          Positioned(
            top: 48,
            right: 28,
            child: _GlowOrb(
              size: 170,
              color: HabitBetTheme.accent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 92,
            left: -40,
            child: _GlowOrb(
              size: 150,
              color: HabitBetTheme.success.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -20,
            child: _GlowOrb(
              size: 240,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          SafeArea(
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topHeight = math.min(size.height * 0.36, 310.0);
    for (var index = 0; index < 38; index++) {
      final x = (((index * 53) % 100) / 100) * size.width;
      final y = (((index * 37 + 11) % 100) / 100) * topHeight;
      final radius = index % 5 == 0 ? 3.4 : 1.9;
      final color = index % 4 == 0
          ? HabitBetTheme.accent.withValues(alpha: 0.44)
          : Colors.white.withValues(alpha: 0.28);
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

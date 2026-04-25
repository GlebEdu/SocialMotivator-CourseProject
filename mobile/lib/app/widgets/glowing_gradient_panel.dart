import 'package:flutter/material.dart';

import '../app_theme.dart';

class GlowingGradientPanel extends StatelessWidget {
  const GlowingGradientPanel({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 30,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0x52FFFFFF),
            Color(0x24FFFFFF),
            Color(0x10FFFFFF),
            Color(0x30FFFFFF),
          ],
          stops: <double>[0, 0.24, 0.72, 1],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: <BoxShadow>[
          ...HabitBetTheme.softShadow(),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.06),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: HabitBetTheme.panelGradient(),
            borderRadius: BorderRadius.circular(radius - 1),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

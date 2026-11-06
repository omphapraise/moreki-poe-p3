import 'package:flutter/material.dart';

/// A soft accent glow that fades from [color] into the black canvas.
/// Wrap the top section of a screen with it. One glow per screen.
/// It is a plain gradient (no blur), so it is cheap on low-end phones.
class AccentGlow extends StatelessWidget {
  const AccentGlow({super.key, required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: child,
    );
  }
}
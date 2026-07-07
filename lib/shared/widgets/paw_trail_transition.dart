import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PawTrailTransition extends StatelessWidget {
  final Widget child;
  const PawTrailTransition({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // A placeholder for the actual paw trail animation,
    // currently wrapping route transitions with a springy slide and fade.
    return child.animate().fade(duration: 400.ms, curve: Curves.easeOut).slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingContainer extends StatelessWidget {
  final Widget child;
  const BreathingContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.03, 1.03),
          duration: 3000.ms,
          curve: Curves.easeInOutSine,
        );
  }
}

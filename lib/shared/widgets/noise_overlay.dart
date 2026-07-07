import 'package:flutter/material.dart';

class NoiseOverlay extends StatelessWidget {
  final Widget child;
  const NoiseOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/noise.png',
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              // Blend mode and opacity handle the fine film-grain overlay
              opacity: const AlwaysStoppedAnimation(0.8), // Image itself is 4% alpha, so 0.8 is fine
              colorBlendMode: BlendMode.overlay,
            ),
          ),
        ),
      ],
    );
  }
}

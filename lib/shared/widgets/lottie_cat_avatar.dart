import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieCatAvatar extends StatefulWidget {
  final double size;
  final String assetPath;

  const LottieCatAvatar({
    super.key,
    this.size = 240,
    this.assetPath = 'assets/animations/cat_default.json',
  });

  @override
  State<LottieCatAvatar> createState() => _LottieCatAvatarState();
}

class _LottieCatAvatarState extends State<LottieCatAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLoaded = false; // Intentionally kept for state rebuilds

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Default duration, will be overridden by Lottie composition
    );
  }

  @override
  void didUpdateWidget(covariant LottieCatAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _controller.reset();
      setState(() {
        _isLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: Lottie.asset(
          widget.assetPath,
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.repeat(); // Loop the animation
            setState(() {
              _isLoaded = true;
            });
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback UI if the cat.json isn't there yet
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: widget.size * 0.4, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Waiting for Lottie file...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

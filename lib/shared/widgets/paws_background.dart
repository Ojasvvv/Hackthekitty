import 'package:flutter/material.dart';
import 'dart:math' as math;

class PawsBackground extends StatelessWidget {
  const PawsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _PawsPainter(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}

class _PawsPainter extends CustomPainter {
  final Color color;

  _PawsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Instantiate Random INSIDE paint with a fixed seed so it always generates
    // the exact same sequence on every single repaint, keeping the paws completely static.
    final random = math.Random(42);

    // Staggered grid spacing
    const double spacingX = 80;
    const double spacingY = 100;
    
    for (double x = -50; x < size.width + 50; x += spacingX) {
      for (double y = -50; y < size.height + 50; y += spacingY) {
        // Add random jitter to position
        final offsetX = x + (random.nextDouble() * 40 - 20);
        final offsetY = y + (random.nextDouble() * 40 - 20);
        
        // Random rotation
        final rotation = random.nextDouble() * 2 * math.pi;
        // Random scale (size)
        final scale = 0.8 + (random.nextDouble() * 0.6); // 0.8 to 1.4

        canvas.save();
        canvas.translate(offsetX, offsetY);
        canvas.rotate(rotation);
        canvas.scale(scale);

        textPainter.text = TextSpan(
          text: String.fromCharCode(Icons.pets.codePoint),
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontFamily: Icons.pets.fontFamily,
            package: Icons.pets.fontPackage,
          ),
        );
        
        textPainter.layout();
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

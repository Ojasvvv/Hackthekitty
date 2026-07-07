import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../features/mood_engine/mood_provider.dart';
import '../theme/mood_palette.dart';

class LivingCatAvatar extends ConsumerStatefulWidget {
  final double size;
  const LivingCatAvatar({super.key, this.size = 240});

  @override
  ConsumerState<LivingCatAvatar> createState() => _LivingCatAvatarState();
}

class _LivingCatAvatarState extends ConsumerState<LivingCatAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(moodTierProvider);
    final palette = MoodPalette.fromTier(currentTier, Theme.of(context).brightness);
    final healthAsync = ref.watch(healthSnapshotProvider);

    // Derive scores from snapshot or use defaults
    double activityScore = 0.5;
    if (healthAsync.hasValue && healthAsync.value != null) {
      final snapshot = healthAsync.value!;
      activityScore = (snapshot.stepCount / 10000.0).clamp(0.0, 1.0);
    }

    // Adjust breathing speed based on activity
    _breathingController.duration = Duration(milliseconds: 3500 - (activityScore * 1500).toInt());

    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        final breathScale = 1.0 + (_breathingController.value * 0.03);
        
        return Transform.scale(
          scale: breathScale,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CatPainter(
              palette: palette,
              activityScore: activityScore,
              breathValue: _breathingController.value,
            ),
          ),
        );
      },
    );
  }
}

class _CatPainter extends CustomPainter {
  final MoodPalette palette;
  final double activityScore;
  final double breathValue;

  _CatPainter({
    required this.palette,
    required this.activityScore,
    required this.breathValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.35;

    // Head Base
    final headPaint = Paint()
      ..color = palette.accent
      ..style = PaintingStyle.fill;
    
    // Add soft shadow under head
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: headRadius)),
      Colors.black.withValues(alpha: 0.1),
      4.0,
      true,
    );

    canvas.drawCircle(center, headRadius, headPaint);

    // Ears
    final earPaint = Paint()
      ..color = palette.accent
      ..style = PaintingStyle.fill;
    
    final innerEarPaint = Paint()
      ..color = palette.surface
      ..style = PaintingStyle.fill;

    _drawEar(canvas, center, headRadius, -math.pi / 4, earPaint, innerEarPaint, activityScore);
    _drawEar(canvas, center, headRadius, -math.pi * 3 / 4, earPaint, innerEarPaint, activityScore);

    // Eyes
    final eyePaint = Paint()
      ..color = palette.background
      ..style = PaintingStyle.fill;
      
    // Eyes open/alert based on activity score
    final eyeHeight = headRadius * 0.10 + (activityScore * headRadius * 0.15);
    final eyeY = center.dy - headRadius * 0.1;
    
    // Left eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - headRadius * 0.4, eyeY), width: headRadius * 0.25, height: eyeHeight),
      eyePaint,
    );
    // Right eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + headRadius * 0.4, eyeY), width: headRadius * 0.25, height: eyeHeight),
      eyePaint,
    );

    // Nose
    final nosePaint = Paint()
      ..color = palette.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy + headRadius * 0.2), headRadius * 0.08, nosePaint);

    // Whiskers (moving with breath)
    final whiskerPaint = Paint()
      ..color = palette.primaryText.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final whiskerYOffset = breathValue * 5;
    
    // Left Whiskers
    canvas.drawLine(Offset(center.dx - headRadius * 0.3, center.dy + headRadius * 0.3), Offset(center.dx - headRadius * 0.8, center.dy + headRadius * 0.2 + whiskerYOffset), whiskerPaint);
    canvas.drawLine(Offset(center.dx - headRadius * 0.3, center.dy + headRadius * 0.4), Offset(center.dx - headRadius * 0.85, center.dy + headRadius * 0.4 + whiskerYOffset), whiskerPaint);
    
    // Right Whiskers
    canvas.drawLine(Offset(center.dx + headRadius * 0.3, center.dy + headRadius * 0.3), Offset(center.dx + headRadius * 0.8, center.dy + headRadius * 0.2 + whiskerYOffset), whiskerPaint);
    canvas.drawLine(Offset(center.dx + headRadius * 0.3, center.dy + headRadius * 0.4), Offset(center.dx + headRadius * 0.85, center.dy + headRadius * 0.4 + whiskerYOffset), whiskerPaint);
  }

  void _drawEar(Canvas canvas, Offset center, double headRadius, double angle, Paint earPaint, Paint innerEarPaint, double activity) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    
    // Ear twitch based on activity
    final twitch = math.sin(DateTime.now().millisecondsSinceEpoch / 200.0) * (activity * 0.1);
    canvas.rotate(twitch);

    final earPath = Path()
      ..moveTo(0, -headRadius * 0.8)
      ..lineTo(headRadius * 0.4, -headRadius * 1.4)
      ..lineTo(headRadius * 0.8, -headRadius * 0.4)
      ..close();
      
    canvas.drawPath(earPath, earPaint);
    
    final innerEarPath = Path()
      ..moveTo(headRadius * 0.2, -headRadius * 0.7)
      ..lineTo(headRadius * 0.4, -headRadius * 1.1)
      ..lineTo(headRadius * 0.6, -headRadius * 0.5)
      ..close();

    canvas.drawPath(innerEarPath, innerEarPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    // Continuous repainting is fine here because of AnimatedBuilder
    return true; 
  }
}

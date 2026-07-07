import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'breathing_container.dart';
import '../theme/mood_palette.dart';
import '../../features/mood_engine/mood_provider.dart';

class CatPlaceholder extends ConsumerWidget {
  final double size;
  const CatPlaceholder({super.key, this.size = 200});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(moodTierProvider);
    final palette = MoodPalette.fromTier(currentTier, Theme.of(context).brightness);

    return BreathingContainer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.accent.withValues(alpha: 0.15),
          border: Border.all(color: palette.accent, width: 4),
        ),
        child: Center(
          child: Icon(
            Icons.pets,
            size: size * 0.4,
            color: palette.accent,
          ),
        ),
      ),
    );
  }
}

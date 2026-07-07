import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/economy/treat_repository.dart';

class HydrationNotifier extends Notifier<int> {
  @override
  int build() => 0; // Simple daily counter

  void drinkGlass() {
    state++;
    ref.read(treatCountProvider.notifier).addTreats(5);
  }
}

final hydrationProvider = NotifierProvider<HydrationNotifier, int>(() {
  return HydrationNotifier();
});

class HydrationCard extends ConsumerWidget {
  const HydrationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final glasses = ref.watch(hydrationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900.withValues(alpha: 0.8),
            Colors.blue.shade700.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Water Droplet Icon with fill animation
          GestureDetector(
            onTap: () {
              ref.read(hydrationProvider.notifier).drinkGlass();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200.withValues(alpha: 0.5), width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.water_drop_outlined, color: Colors.blue.shade200, size: 32),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: (glasses / 8).clamp(0.0, 1.0), // Goal of 8 glasses
                      child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(key: ValueKey(glasses)).scale(begin: const Offset(0.8, 0.8), duration: 200.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hydration Station',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$glasses / 8 glasses today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
            ),
            child: const Text(
              '+5 Treats',
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

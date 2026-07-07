import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/health/health_snapshot.dart';
import '../../mood_engine/mood_provider.dart';
import '../../../shared/widgets/lottie_cat_avatar.dart';

class ChallengesList extends ConsumerWidget {
  const ChallengesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSnapshotAsync = ref.watch(healthSnapshotProvider);
    final theme = Theme.of(context);
    
    return healthSnapshotAsync.when(
      data: (snapshot) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Text(
              'Daily Challenges',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: Color(0xFF3A3532), // ink
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete challenges to earn virtual treats for your cat.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF6B625B), // inkSoft
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: LottieCatAvatar(
                size: 160,
                assetPath: 'assets/animations/cat_playing.json',
              ),
            ),
            const SizedBox(height: 24),
            _ChallengeCard(
              title: 'The Zoomies',
              description: 'Walk 10,000 steps today',
              currentValue: snapshot.stepCount.toDouble(),
              targetValue: 10000.0,
              rewardText: '3 Treats',
              icon: Icons.directions_run_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _ChallengeCard(
              title: 'Prowling',
              description: 'Walk 5,000 steps today',
              currentValue: snapshot.stepCount.toDouble(),
              targetValue: 5000.0,
              rewardText: '1 Treat',
              icon: Icons.pets_rounded,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            _ChallengeCard(
              title: 'Cat Nap',
              description: 'Keep screen time under 3 hours',
              // Reverse progress for screen time
              currentValue: (3.0 - snapshot.screenTimeHours).clamp(0.0, 3.0),
              targetValue: 3.0,
              rewardText: '2 Treats',
              icon: Icons.smartphone_rounded,
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 100),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      error: (e, st) => Center(child: Text('Unable to load challenges.', style: theme.textTheme.bodyLarge)),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String rewardText;
  final IconData icon;
  final Color color;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.rewardText,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentValue / targetValue).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // white
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF3A3532), // ink
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCD0BC), // line
            offset: Offset(4, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF3A3532), // ink
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF6B625B), // inkSoft
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFC94C), // butter
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF3A3532), width: 1.5), // ink
                ),
                child: Row(
                  children: [
                    Text(
                      rewardText,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF3A3532), // ink
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A3532), width: 1.5),
                borderRadius: BorderRadius.circular(100),
                color: const Color(0xFFF3EBDC), // paperDeep
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF7C9082) : color, // sage or original color
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isCompleted ? const Color(0xFF5F7568) : color, // sageDeep or color
                ),
              ),
              if (isCompleted)
                const Text(
                  'Completed!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF5F7568), // sageDeep
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

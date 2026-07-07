import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/economy/treat_repository.dart';
import '../../../mood_engine/mood_provider.dart';
import '../../../../shared/theme/mood_palette.dart';

class VibeCheckCard extends ConsumerStatefulWidget {
  const VibeCheckCard({super.key});

  @override
  ConsumerState<VibeCheckCard> createState() => _VibeCheckCardState();
}

class _VibeCheckCardState extends ConsumerState<VibeCheckCard> {
  double _sliderValue = 2; // neutral
  bool _submitted = false;

  void _submitMood() {
    setState(() => _submitted = true);
    final tier = MoodTier.values[_sliderValue.round()];
    ref.read(moodTierProvider.notifier).setMood(tier);
    ref.read(treatCountProvider.notifier).addTreats(10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibe Check',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (!_submitted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+10 Treats',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _submitted ? 'Thanks for checking in today! 🐾' : 'How are you feeling right now?',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!_submitted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Awful', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Amazing', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 4,
              divisions: 4,
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.primary.withValues(alpha: 0.2),
              onChanged: (val) => setState(() => _sliderValue = val),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: _submitMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Log Mood'),
              ),
            ),
          ] else ...[
            Center(
              child: Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 48),
            ),
          ]
        ],
      ),
    );
  }
}

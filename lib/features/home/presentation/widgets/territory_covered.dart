import 'package:flutter/material.dart';
import '../../../../shared/widgets/bespoke_bar_chart.dart';
import '../../../../core/health/health_snapshot.dart';
import 'dart:math' as math;

class InsightsCard extends StatelessWidget {
  final HealthSnapshot snapshot;

  const InsightsCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Simulate 7-day data based on today's snapshot for demo purposes
    // In a real app, this would be fetched from HealthRepository's historical data
    final random = math.Random(42);
    final values = List.generate(6, (i) => 2000.0 + random.nextDouble() * 8000.0);
    values.add(snapshot.stepCount.toDouble()); // Today's real data
    
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
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
          Text(
            'Weekly Prowl',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your step history over the last 7 days.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          BespokeBarChart(
            values: values,
            labels: labels,
            maxValue: 12000.0,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

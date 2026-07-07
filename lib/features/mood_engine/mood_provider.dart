import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/mood_palette.dart';
import '../../core/health/health_repository.dart';
import '../../core/health/health_snapshot.dart';
import 'mood_engine.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

final healthSnapshotProvider = FutureProvider<HealthSnapshot>((ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  return repo.getLatestSnapshot();
});

class MoodTierNotifier extends Notifier<MoodTier> {
  @override
  MoodTier build() {
    final snapshotAsync = ref.watch(healthSnapshotProvider);
    return snapshotAsync.maybeWhen(
      data: (snapshot) => MoodEngine.calculateMoodTier(snapshot),
      orElse: () => MoodTier.neutral,
    );
  }

  void setMood(MoodTier newTier) {
    state = newTier;
  }
}

final moodTierProvider = NotifierProvider<MoodTierNotifier, MoodTier>(() {
  return MoodTierNotifier();
});

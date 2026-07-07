import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import '../../features/mood_engine/mood_provider.dart';
import '../../core/health/health_snapshot.dart';
import 'breathing_container.dart';

class RiveCatCharacter extends ConsumerStatefulWidget {
  final double size;
  const RiveCatCharacter({super.key, this.size = 240});

  @override
  ConsumerState<RiveCatCharacter> createState() => _RiveCatCharacterState();
}

class _RiveCatCharacterState extends ConsumerState<RiveCatCharacter> {
  // New Rive 0.14.x types — the old SMINumber no longer exists.
  NumberInput? _sleepScoreInput;
  NumberInput? _activityScoreInput;
  NumberInput? _restlessnessScoreInput;
  NumberInput? _timeOfDayInput;

  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      'assets/rive/cat.riv',
      riveFactory: Factory.flutter,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  void _onRiveLoaded(RiveLoaded state) {
    final sm = state.controller.stateMachine;
    // SM inputs are deprecated in favour of data-binding, but we have no
    // .riv file with view-models yet — safe to use for now.
    // ignore: deprecated_member_use
    _sleepScoreInput = sm.number('sleep_score');
    // ignore: deprecated_member_use
    _activityScoreInput = sm.number('activity_score');
    // ignore: deprecated_member_use
    _restlessnessScoreInput = sm.number('restlessness_score');
    // ignore: deprecated_member_use
    _timeOfDayInput = sm.number('time_of_day');
  }

  void _updateRiveInputs(HealthSnapshot snapshot) {
    // Normalizing scores out of 1.0 based on our engine
    // We assume 10k steps is perfect activity (1.0)
    final sleepScore = 1.0; // Hardcoded since sleep is no longer tracked
    final activityScore = (snapshot.stepCount / 10000).clamp(0.0, 1.0);
    final restlessnessScore = (snapshot.lateNightPickups / 5.0).clamp(0.0, 1.0);

    _sleepScoreInput?.value = sleepScore;
    _activityScoreInput?.value = activityScore;
    _restlessnessScoreInput?.value = restlessnessScore;
    _timeOfDayInput?.value = snapshot.timeOfDay;
  }

  @override
  Widget build(BuildContext context) {
    final healthSnapshotAsync = ref.watch(healthSnapshotProvider);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: healthSnapshotAsync.when(
        data: (snapshot) {
          _updateRiveInputs(snapshot);

          return BreathingContainer(
            child: RiveWidgetBuilder(
              fileLoader: _fileLoader,
              stateMachineSelector:
                  const StateMachineNamed('MoodStateMachine'),
              onLoaded: _onRiveLoaded,
              builder: (context, state) {
                return switch (state) {
                  RiveLoaded(:final controller) => RiveWidget(
                      controller: controller,
                      fit: Fit.contain,
                    ),
                  RiveFailed() =>
                    const Icon(Icons.error_outline),
                  RiveLoading() =>
                    const Center(child: CircularProgressIndicator()),
                };
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Icon(Icons.error_outline),
      ),
    );
  }
}

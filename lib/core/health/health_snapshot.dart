class HealthSnapshot {
  final int stepCount;
  final double screenTimeHours;
  final int lateNightPickups;
  final double timeOfDay; // 0.0 to 24.0

  const HealthSnapshot({
    required this.stepCount,
    required this.screenTimeHours,
    required this.lateNightPickups,
    required this.timeOfDay,
  });

  factory HealthSnapshot.fallback() {
    final now = DateTime.now();
    return HealthSnapshot(
      stepCount: 0,
      screenTimeHours: 3.0,
      lateNightPickups: 0,
      timeOfDay: now.hour + now.minute / 60.0,
    );
  }

  // Virtual Pet gamification: 1 treat for every 3000 steps
  int get earnedTreats => stepCount ~/ 3000;
}

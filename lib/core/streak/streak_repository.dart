import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final streakProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  
  final lastOpenStr = prefs.getString('last_open_date');
  final currentStreak = prefs.getInt('current_streak') ?? 0;
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  if (lastOpenStr == null) {
    // First time opening app
    await prefs.setString('last_open_date', today.toIso8601String());
    await prefs.setInt('current_streak', 1);
    return 1;
  }
  
  final lastOpen = DateTime.parse(lastOpenStr);
  final difference = today.difference(lastOpen).inDays;
  
  if (difference == 0) {
    // Already opened today, streak remains the same
    return currentStreak;
  } else if (difference == 1) {
    // Opened yesterday, streak increments
    final newStreak = currentStreak + 1;
    await prefs.setString('last_open_date', today.toIso8601String());
    await prefs.setInt('current_streak', newStreak);
    return newStreak;
  } else {
    // Missed a day or more, streak resets
    await prefs.setString('last_open_date', today.toIso8601String());
    await prefs.setInt('current_streak', 1);
    return 1;
  }
});

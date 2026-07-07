import 'dart:io';
import 'package:health/health.dart';
import 'package:usage_stats/usage_stats.dart';
import 'health_snapshot.dart';

class HealthRepository {
  final Health _health = Health();

  Future<bool> checkPermissions() async {
    bool usageGranted = true;
    if (Platform.isAndroid) {
      usageGranted = await UsageStats.checkUsagePermission() ?? false;
    }

    return usageGranted; // Only strictly require Usage stats
  }

  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.STEPS,
    ];
    final permissions = [
      HealthDataAccess.READ,
    ];
    
    try {
      await _health.requestAuthorization(types, permissions: permissions).timeout(const Duration(seconds: 5));
      if (Platform.isAndroid) {
        await _health.requestHealthDataInBackgroundAuthorization().timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Ignore if health connect is not installed or cancelled
    }
    
    if (Platform.isAndroid) {
      bool usageGranted = await UsageStats.checkUsagePermission() ?? false;
      if (!usageGranted) {
        await UsageStats.grantUsagePermission();
        return false; // Still need user to grant it in settings
      }
    }
    
    return true; // Health is optional, Usage is required
  }

  Future<HealthSnapshot> getLatestSnapshot() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Get Steps
      int? steps;
      try {
        steps = await _health.getTotalStepsInInterval(startOfDay, now).timeout(const Duration(seconds: 3));
      } catch (_) {}
      
      // Get Screen Time & Pickups
      double screenTimeHours = 0.0; // default
      int lateNightPickups = 0;
      
      if (Platform.isAndroid) {
        List<EventUsageInfo> events = await UsageStats.queryEvents(startOfDay, now);
        int totalScreenTimeMs = 0;
        int lastInteractive = 0;
        
        for (var e in events) {
          if (e.eventType == '15') { // SCREEN_INTERACTIVE
            lastInteractive = int.parse(e.timeStamp ?? '0');
            
            final eventDate = DateTime.fromMillisecondsSinceEpoch(lastInteractive);
            if (eventDate.hour < 5) {
              lateNightPickups++;
            }
          } else if (e.eventType == '16') { // SCREEN_NON_INTERACTIVE
            if (lastInteractive > 0) {
              totalScreenTimeMs += int.parse(e.timeStamp ?? '0') - lastInteractive;
              lastInteractive = 0;
            }
          }
        }
        if (lastInteractive > 0) {
          totalScreenTimeMs += now.millisecondsSinceEpoch - lastInteractive;
        }
        screenTimeHours = totalScreenTimeMs / (1000 * 60 * 60);
      }

      return HealthSnapshot(
        stepCount: steps ?? 0,
        screenTimeHours: screenTimeHours,
        lateNightPickups: lateNightPickups,
        timeOfDay: now.hour + now.minute / 60.0,
      );
    } catch (e) {
      print('Health API Error: $e');
      return HealthSnapshot.fallback();
    }
  }

  Future<double?> getPreviousDayScreenTimeHours() async {
    if (!Platform.isAndroid) return null;
    
    try {
      final now = DateTime.now();
      final endOfYesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(milliseconds: 1));
      final startOfYesterday = DateTime(endOfYesterday.year, endOfYesterday.month, endOfYesterday.day);

      List<EventUsageInfo> events = await UsageStats.queryEvents(startOfYesterday, endOfYesterday);
      int totalScreenTimeMs = 0;
      int lastInteractive = 0;
      
      for (var e in events) {
        if (e.eventType == '15') { // SCREEN_INTERACTIVE
          lastInteractive = int.parse(e.timeStamp ?? '0');
        } else if (e.eventType == '16') { // SCREEN_NON_INTERACTIVE
          if (lastInteractive > 0) {
            totalScreenTimeMs += int.parse(e.timeStamp ?? '0') - lastInteractive;
            lastInteractive = 0;
          }
        }
      }
      if (lastInteractive > 0) {
        totalScreenTimeMs += endOfYesterday.millisecondsSinceEpoch - lastInteractive;
      }
      return totalScreenTimeMs / (1000 * 60 * 60);
    } catch (e) {
      print('Error getting previous day screen time: $e');
      return null;
    }
  }
}

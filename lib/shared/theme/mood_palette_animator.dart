import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_provider.dart';
import '../../features/mood_engine/mood_provider.dart';

class MoodPaletteAnimator extends ConsumerWidget {
  final Widget child;
  const MoodPaletteAnimator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(moodTierProvider);
    final themeMode = ref.watch(themeProvider);
    
    // Resolve brightness based on theme mode
    Brightness brightness;
    if (themeMode == ThemeMode.system) {
      // For simplicity, default to platform brightness
      brightness = MediaQuery.platformBrightnessOf(context);
    } else {
      brightness = themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    }

    final themeData = AppTheme.getThemeData(brightness);

    return AnimatedTheme(
      data: themeData,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

enum MoodTier {
  depleted,
  low,
  neutral,
  good,
  thriving,
}

class MoodPalette {
  final Color background;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;

  const MoodPalette({
    required this.background,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
  });

  static const MoodPalette depleted = MoodPalette(
    background: Color(0xFFF8F9FA), // Professional Off-White
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF212529),
    secondaryText: Color(0xFF6C757D),
    accent: Color(0xFF6C757D), // Slate Gray
  );

  static const MoodPalette low = MoodPalette(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF212529),
    secondaryText: Color(0xFF6C757D),
    accent: Color(0xFF495057),
  );

  static const MoodPalette neutral = MoodPalette(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF212529),
    secondaryText: Color(0xFF6C757D),
    accent: Color(0xFF343A40),
  );

  static const MoodPalette good = MoodPalette(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF212529),
    secondaryText: Color(0xFF6C757D),
    accent: Color(0xFF212529),
  );

  static const MoodPalette thriving = MoodPalette(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    primaryText: Color(0xFF212529),
    secondaryText: Color(0xFF6C757D),
    accent: Color(0xFF000000),
  );

  static const MoodPalette darkDepleted = MoodPalette(
    background: Color(0xFF121212), // Deep Professional Black
    surface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF8F9FA),
    secondaryText: Color(0xFFADB5BD),
    accent: Color(0xFF6C757D),
  );

  static const MoodPalette darkLow = MoodPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF8F9FA),
    secondaryText: Color(0xFFADB5BD),
    accent: Color(0xFF868E96),
  );

  static const MoodPalette darkNeutral = MoodPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF8F9FA),
    secondaryText: Color(0xFFADB5BD),
    accent: Color(0xFFCED4DA),
  );

  static const MoodPalette darkGood = MoodPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF8F9FA),
    secondaryText: Color(0xFFADB5BD),
    accent: Color(0xFFE9ECEF),
  );

  static const MoodPalette darkThriving = MoodPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primaryText: Color(0xFFF8F9FA),
    secondaryText: Color(0xFFADB5BD),
    accent: Color(0xFFFFFFFF),
  );

  static MoodPalette fromTier(MoodTier tier, Brightness brightness) {
    if (brightness == Brightness.dark) {
      switch (tier) {
        case MoodTier.depleted: return darkDepleted;
        case MoodTier.low: return darkLow;
        case MoodTier.neutral: return darkNeutral;
        case MoodTier.good: return darkGood;
        case MoodTier.thriving: return darkThriving;
      }
    } else {
      switch (tier) {
        case MoodTier.depleted: return depleted;
        case MoodTier.low: return low;
        case MoodTier.neutral: return neutral;
        case MoodTier.good: return good;
        case MoodTier.thriving: return thriving;
      }
    }
  }
}

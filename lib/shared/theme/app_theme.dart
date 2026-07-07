import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final paper = isDark ? AppColors.darkPaper : AppColors.paper;
    final paperDeep = isDark ? AppColors.darkPaperDeep : AppColors.paperDeep;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final inkSoft = isDark ? AppColors.darkInkSoft : AppColors.inkSoft;
    final line = isDark ? AppColors.darkLine : AppColors.line;
    final white = isDark ? AppColors.darkWhite : AppColors.white;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.marmalade,
        brightness: brightness,
        surface: white,
        onSurface: ink,
        primary: AppColors.marmalade,
        onPrimary: AppColors.white,
        secondary: AppColors.sage,
        tertiary: AppColors.butter,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headlineLarge.copyWith(color: ink),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: ink),
        titleLarge: AppTypography.headlineMedium.copyWith(fontSize: 20, color: ink),
        titleMedium: AppTypography.headlineMedium.copyWith(fontSize: 16, color: ink),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: ink),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: inkSoft),
        labelLarge: AppTypography.labelLarge.copyWith(color: ink),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: ink, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.marmalade,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: ink, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

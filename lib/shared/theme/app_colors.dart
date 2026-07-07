import 'package:flutter/material.dart';

class AppColors {
  // Light Mode (Paper Aesthetic)
  static const Color paper = Color(0xFFFBF6EE);
  static const Color paperDeep = Color(0xFFF3EBDC);
  static const Color ink = Color(0xFF3A3532);
  static const Color inkSoft = Color(0xFF6B625B);
  static const Color line = Color(0xFFDCD0BC);
  static const Color white = Color(0xFFFFFDF9);

  // Brand Colors (Shared across themes)
  static const Color marmalade = Color(0xFFE8815A);
  static const Color marmaladeDeep = Color(0xFFD66B44);
  static const Color sage = Color(0xFF7C9082);
  static const Color sageDeep = Color(0xFF5F7568);
  static const Color butter = Color(0xFFEFC94C);

  // Dark Mode (Dark Paper/Slate Aesthetic)
  static const Color darkPaper = Color(0xFF1E1C1A);
  static const Color darkPaperDeep = Color(0xFF2A2623);
  static const Color darkInk = Color(0xFFFBF6EE); // Text and borders are light in dark mode
  static const Color darkInkSoft = Color(0xFFA8A099);
  static const Color darkLine = Color(0xFF443F3B);
  static const Color darkWhite = Color(0xFF25221F); // Dark variant for cards
}

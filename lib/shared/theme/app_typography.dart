import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Playful, soft rounded font for headlines
  static final TextStyle headlineLarge = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static final TextStyle headlineMedium = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // Clean, soft sans-serif for body
  static final TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static final TextStyle labelLarge = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static final TextStyle h1 = GoogleFonts.dmSans(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static final TextStyle h2 = GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static final TextStyle h3 = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle h4 = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );


  static final TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyXSmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );


  static final TextStyle bodyStrong = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle overline = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    color: AppColors.primary,
  );

  static final TextStyle captionEmphasis = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelMedium = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: AppColors.textPrimary,
  );

  static final TextStyle labelSmall = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle link = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );


  static final TextStyle buttonPrimary = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    color: AppColors.textOnPrimary,
  );

  static final TextStyle buttonSecondary = labelLarge;

  static final TextStyle numericDisplay = GoogleFonts.dmSans(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineMedium: h4,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: buttonSecondary,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
      titleMedium: bodyStrong,
      titleSmall: bodyXSmall,
    );
  }

}

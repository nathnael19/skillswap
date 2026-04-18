import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';

class SessionProgressHeader extends StatelessWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final String label;
  final String title;
  final String quote;

  const SessionProgressHeader({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    required this.label,
    required this.title,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.overlay05,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.overlay10),
              ),
              child: Row(
                children: [
                  Text(
                    currentStep.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    ' / $totalSteps',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.overlay30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Premium Glassy Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.overlay05,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentColor, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '“$quote”',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: AppColors.overlay40,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

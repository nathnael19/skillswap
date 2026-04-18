import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';

class GuestWall extends StatelessWidget {
  final String title;
  final String description;

  const GuestWall({
    super.key,
    this.title = "Sign in required",
    this.description =
        "You need to be logged in to view this content and interact with others.",
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    const darkBg = AppColors.background;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: darkBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Lock Icon Container
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.02),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.lock_rounded, size: 56, color: accentColor),
          ),
          const SizedBox(height: 48),

          // Typography Section
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppColors.overlay40,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),

          // Primary Action Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentColor, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, OnboardingPage.route()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textPrimary,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Sign In / Sign Up',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

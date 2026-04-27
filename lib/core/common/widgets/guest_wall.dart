import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
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
    final hPad = Responsive.contentHorizontalPadding(context);
    final iconOuter = Responsive.valueFor<double>(
      context,
      compact: 24,
      mobile: 28,
      tablet: 30,
      tabletWide: 32,
      desktop: 32,
    );
    final iconSize = Responsive.valueFor<double>(
      context,
      compact: 44,
      mobile: 52,
      tablet: 54,
      tabletWide: 56,
      desktop: 56,
    );
    final titleSize = Responsive.valueFor<double>(
      context,
      compact: 22,
      mobile: 26,
      tablet: 28,
      tabletWide: 28,
      desktop: 30,
    );
    final bodySize = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 15,
      tablet: 16,
      tabletWide: 16,
      desktop: 17,
    );
    final vGap = Responsive.valueFor<double>(
      context,
      compact: 32,
      mobile: 40,
      tablet: 44,
      tabletWide: 48,
      desktop: 48,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      color: darkBg,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Lock Icon Container
          Container(
            padding: EdgeInsets.all(iconOuter),
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
            child: Icon(Icons.lock_rounded, size: iconSize, color: accentColor),
          ),
          SizedBox(height: vGap),

          // Typography Section
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: Responsive.valueFor<double>(context, compact: 12, mobile: 14, tablet: 16, tabletWide: 16, desktop: 16)),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: bodySize,
              color: AppColors.overlay40,
              height: 1.6,
            ),
          ),
          SizedBox(height: vGap),

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
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.valueFor<double>(
                    context,
                    compact: 16,
                    mobile: 18,
                    tablet: 20,
                    tabletWide: 20,
                    desktop: 20,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Sign In / Sign Up',
                style: GoogleFonts.dmSans(
                  fontSize: bodySize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

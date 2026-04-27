import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthError = message == 'LOGIN_REQUIRED';
    final hPad = Responsive.contentHorizontalPadding(context);
    final vPad = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 20,
      tablet: 22,
      tabletWide: 24,
      desktop: 24,
    );
    final iconSize = Responsive.valueFor<double>(
      context,
      compact: 40,
      mobile: 44,
      tablet: 46,
      tabletWide: 48,
      desktop: 48,
    );
    final titleSize = Responsive.valueFor<double>(
      context,
      compact: 18,
      mobile: 20,
      tablet: 21,
      tabletWide: 22,
      desktop: 22,
    );
    final bodySize = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 15,
      tablet: 16,
      tabletWide: 16,
      desktop: 17,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.valueFor<double>(
                context,
                compact: 18,
                mobile: 20,
                tablet: 22,
                tabletWide: 24,
                desktop: 24,
              )),
              decoration: BoxDecoration(
                color: isAuthError
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthError
                    ? Icons.lock_outline_rounded
                    : Icons.error_outline_rounded,
                color: isAuthError ? AppColors.primary : AppColors.error,
                size: iconSize,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 18, mobile: 20, tablet: 22, tabletWide: 24, desktop: 24)),
            Text(
              isAuthError ? "Sign in required" : "Something went wrong",
              style: GoogleFonts.dmSans(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 10, mobile: 11, tablet: 12, tabletWide: 12, desktop: 12)),
            Text(
              isAuthError
                  ? "You need to be logged in to view this content and interact with others."
                  : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: bodySize,
                color: AppColors.overlay60,
                height: 1.5,
              ),
            ),
            SizedBox(height: Responsive.valueFor<double>(context, compact: 24, mobile: 28, tablet: 30, tabletWide: 32, desktop: 32)),
            ElevatedButton(
              onPressed: isAuthError
                  ? () => Navigator.of(context).push(OnboardingPage.route())
                  : onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAuthError
                    ? AppColors.primary
                    : AppColors.overlay10,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.valueFor<double>(
                    context,
                    compact: 24,
                    mobile: 28,
                    tablet: 30,
                    tabletWide: 32,
                    desktop: 32,
                  ),
                  vertical: Responsive.valueFor<double>(
                    context,
                    compact: 14,
                    mobile: 15,
                    tablet: 16,
                    tabletWide: 16,
                    desktop: 16,
                  ),
                ),
              ),
              child: Text(
                isAuthError ? 'Sign In / Sign Up' : 'Try Again',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: bodySize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

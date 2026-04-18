import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError ? "Sign in required" : "Something went wrong",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAuthError
                  ? "You need to be logged in to view this content and interact with others."
                  : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.overlay60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                isAuthError ? 'Sign In / Sign Up' : 'Try Again',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

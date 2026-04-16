import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    ? const Color(0xFFCA8A04).withValues(alpha: 0.1) 
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAuthError ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                color: isAuthError ? const Color(0xFFCA8A04) : const Color(0xFFEF4444),
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError ? "Sign in required" : "Something went wrong",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isAuthError 
                  ? () => Navigator.of(context).push(OnboardingPage.route()) 
                  : onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAuthError ? const Color(0xFFCA8A04) : Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
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

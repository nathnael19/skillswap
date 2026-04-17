import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';

class OnboardingStepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> content;
  final VoidCallback onContinue;
  final Widget? footer;
  final bool isLoading;
  final String ctaLabel;

  const OnboardingStepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.onContinue,
    this.footer,
    this.isLoading = false,
    this.ctaLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 140, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          ...content,
          const SizedBox(height: 56),
          AppButton(
            label: ctaLabel,
            isLoading: isLoading,
            onTap: onContinue,
          ),
          if (footer != null) ...[
            const SizedBox(height: 32),
            footer!,
          ],
        ],
      ),
    );
  }
}

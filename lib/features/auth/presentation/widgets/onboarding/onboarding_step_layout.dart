import 'package:flutter/material.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/theme/theme.dart';

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
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 48),
          ...content,
          const SizedBox(height: 56),
          AppButton(label: ctaLabel, isLoading: isLoading, onTap: onContinue),
          if (footer != null) ...[const SizedBox(height: 32), footer!],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:skillswap/core/common/widgets/app_button.dart';
import 'package:skillswap/core/layout/responsive.dart';
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
    final hPad = Responsive.contentHorizontalPadding(context);
    final topPad = Responsive.valueFor<double>(
      context,
      compact: 100,
      mobile: 120,
      tablet: 100,
      tabletWide: 88,
      desktop: 80,
    );
    final bottomPad = Responsive.valueFor<double>(
      context,
      compact: 28,
      mobile: 32,
      tablet: 36,
      tabletWide: 40,
      desktop: 48,
    ) + MediaQuery.viewInsetsOf(context).bottom;
    final gapLg = Responsive.valueFor<double>(
      context,
      compact: 36,
      mobile: 44,
      tablet: 48,
      tabletWide: 48,
      desktop: 52,
    );
    final gapBeforeCta = Responsive.valueFor<double>(
      context,
      compact: 40,
      mobile: 48,
      tablet: 52,
      tabletWide: 56,
      desktop: 56,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.contentMaxWidthFor(context).isFinite
              ? Responsive.contentMaxWidthFor(context)
              : 560,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2),
              SizedBox(height: Responsive.valueFor<double>(context, compact: 10, mobile: 12, tablet: 12, tabletWide: 12, desktop: 12)),
              Text(
                subtitle,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),

              SizedBox(height: gapLg),
              ...content,
              SizedBox(height: gapBeforeCta),
              AppButton(label: ctaLabel, isLoading: isLoading, onTap: onContinue),
              if (footer != null) ...[
                SizedBox(height: Responsive.valueFor<double>(context, compact: 24, mobile: 28, tablet: 30, tabletWide: 32, desktop: 32)),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

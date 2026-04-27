import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minHeight = Responsive.valueFor<double>(
      context,
      compact: 52,
      mobile: 56,
      tablet: 60,
      tabletWide: 64,
      desktop: 64,
    );
    final iconSize = Responsive.valueFor<double>(
      context,
      compact: 20,
      mobile: 22,
      tablet: 24,
      tabletWide: 24,
      desktop: 24,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.overlay03,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.overlay60, size: iconSize),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.captionEmphasis.copyWith(
                letterSpacing: 1.5,
                color: AppColors.overlay60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

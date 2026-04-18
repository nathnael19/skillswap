import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64, // Standardizing height
        decoration: BoxDecoration(
          color: AppColors.overlay03,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.overlay60, size: 24),
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

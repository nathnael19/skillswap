import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class LikesEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const LikesEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 56,
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 48),
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

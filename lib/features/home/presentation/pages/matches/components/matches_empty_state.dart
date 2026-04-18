import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class MatchesEmptyState extends StatelessWidget {
  const MatchesEmptyState({super.key});

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
              Text("No connections yet", style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Text(
                "Explore experts and start chatting to share skills.",
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

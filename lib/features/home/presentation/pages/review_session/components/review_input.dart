import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/core/theme/app_text_styles.dart';

class ReviewInput extends StatelessWidget {
  final TextEditingController controller;

  const ReviewInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT DID YOU LEARN?',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText:
                  'Sarah was incredibly patient while explaining the fundamentals of Figma auto-layout...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                height: 1.4,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

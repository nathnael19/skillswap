import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 1,
  });

  static const Color kAccent = AppColors.primary;
  static const Color kText = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: kAccent),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    color: kAccent.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  cursorColor: kAccent,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

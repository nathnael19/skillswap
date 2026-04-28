import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

class EndorsementsSection extends StatelessWidget {
  final List<String> endorsementOptions;
  final Set<String> selectedEndorsements;
  final Function(String) onToggle;

  const EndorsementsSection({
    super.key,
    required this.endorsementOptions,
    required this.selectedEndorsements,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILL ENDORSEMENTS',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: endorsementOptions.map((trait) {
            bool isSelected = selectedEndorsements.contains(trait);
            return GestureDetector(
              onTap: () => onToggle(trait),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderDefault,
                  ),
                ),
                child: Text(
                  trait,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

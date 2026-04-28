import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/core/theme/app_text_styles.dart';

class RatingStarsCard extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const RatingStarsCard({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final vPad = Responsive.valueFor<double>(
      context,
      compact: 20,
      mobile: 24,
      tablet: 28,
      tabletWide: 32,
      desktop: 32,
    );
    final star = Responsive.valueFor<double>(
      context,
      compact: 32,
      mobile: 36,
      tablet: 38,
      tabletWide: 40,
      desktop: 44,
    );
    final hStarPad = Responsive.valueFor<double>(
      context,
      compact: 2,
      mobile: 3,
      tablet: 4,
      tabletWide: 4,
      desktop: 4,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: vPad),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            'How was the experience?',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(
            height: Responsive.valueFor<double>(
              context,
              compact: 14,
              mobile: 16,
              tablet: 18,
              tabletWide: 20,
              desktop: 20,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hStarPad),
                  child: Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < rating
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    size: star,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

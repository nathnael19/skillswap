import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';

class RatingSelector extends StatelessWidget {
  final double currentRating;
  final Function(double) onSelect;

  const RatingSelector({
    super.key,
    required this.currentRating,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.overlay03,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.overlay08),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              final ratingVal = index + 1.0;
              final isHighlighted = index < currentRating;
              return GestureDetector(
                onTap: () => onSelect(ratingVal),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    isHighlighted
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.overlay20,
                    size: 30,
                  ),
                ),
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${currentRating.toInt()}.0+',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

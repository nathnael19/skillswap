import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';

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
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'How was the experience?',
            style: GoogleFonts.inter(
              fontSize: Responsive.valueFor<double>(
                context,
                compact: 13,
                mobile: 14,
                tablet: 15,
                tabletWide: 15,
                desktop: 16,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475467),
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
                        ? const Color(0xFF0B6A7A)
                        : const Color(0xFFD0D5DD),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
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
                    isHighlighted ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isHighlighted
                        ? const Color(0xFFCA8A04)
                        : Colors.white.withValues(alpha: 0.2),
                    size: 30,
                  ),
                ),
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCA8A04).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${currentRating.toInt()}.0+',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFCA8A04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

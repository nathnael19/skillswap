import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'How was the experience?',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475467),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < rating
                        ? const Color(0xFF0B6A7A)
                        : const Color(0xFFD0D5DD),
                    size: 40,
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

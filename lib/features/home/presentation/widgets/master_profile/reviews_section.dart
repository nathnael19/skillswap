import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/section_header.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            label: 'COMMUNITY ECHOES',
            title: 'Partner Reviews',
          ),
          const SizedBox(height: 24),
          _buildReviewCard(
            'Julian Chen',
            'Swap: React for Pottery',
            'Elena is a master of her craft. Her patience while teaching me wheel-throwing was incredible. I finally understand the \'soul\' behind ceramics. Highly recommended!',
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Sarah Jenkins',
            'Swap: SEO for Figma',
            'The deep-dive session on Figma components saved me weeks of work. Elena\'s ability to explain complex design systems is unparalleled.',
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Read all 124 reviews',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475467),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String sub, String review) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage('assets/home.png'), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828)),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: const Color(0xFF667085)),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                    5,
                    (i) => const Icon(Icons.star_rounded,
                        color: Color(0xFF9E6400), size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$review"',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF344054),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

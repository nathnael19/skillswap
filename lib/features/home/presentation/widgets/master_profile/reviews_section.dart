import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/section_header.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  static const Color kPrimary = Color(0xFFCA8A04);
  static const Color kSecondary = Colors.white;
  static const Color kTextMuted = Color(0xFF9CA3AF);

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
            titleColor: Colors.white,
            labelColor: kPrimary,
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
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimary.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  'Read all 124 reviews',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                    letterSpacing: 0.5,
                  ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1917),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                      image: AssetImage('assets/home.png'), fit: BoxFit.cover),
                  border: Border.all(
                      color: kPrimary.withValues(alpha: 0.2), width: 2),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => const Icon(Icons.star_rounded,
                      color: Color(0xFFFACC15), size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$review"',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

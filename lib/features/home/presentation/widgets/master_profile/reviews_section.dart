import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/section_header.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';

class ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  const ReviewsSection({super.key, required this.reviews});

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
          SectionHeader(
            label: 'REVIEWS',
            title: '${reviews.length} Partner Reviews',
            titleColor: Colors.white,
            labelColor: kPrimary,
          ),
          const SizedBox(height: 24),
          if (reviews.isEmpty)
            _buildEmptyState()
          else ...[
            ...reviews.map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildReviewCard(review),
                )),
            const SizedBox(height: 8),
            if (reviews.length > 3) _buildLoadMoreButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1917),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: kPrimary.withValues(alpha: 0.4),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            "No reviews yet",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Be the first to swap skills with this expert!",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: kTextMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return InkWell(
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
            'Read all ${reviews.length} reviews',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: kPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
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
                  border: Border.all(
                      color: kPrimary.withValues(alpha: 0.2), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: review.reviewerImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: review.reviewerImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Image.asset('assets/home.png', fit: BoxFit.cover),
                        )
                      : Image.asset('assets/home.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Partner Review', // Could be dynamic if swap type is stored
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    color: i < review.rating.floor()
                        ? const Color(0xFFFACC15)
                        : Colors.white.withValues(alpha: 0.1),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${review.comment}"',
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

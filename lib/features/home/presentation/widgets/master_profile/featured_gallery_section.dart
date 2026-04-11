import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/section_header.dart';

class FeaturedGallerySection extends StatelessWidget {
  const FeaturedGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            label: 'FEATURED GALLERY',
            title: 'Recent Creations',
            actionLabel: 'View All',
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _buildGalleryCard('assets/home.png', 'Stone Collection 2024'),
                const SizedBox(width: 16),
                _buildGalleryCard('assets/home.png', 'Fintech UI Redesign'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(String image, String title) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            stops: const [0.6, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

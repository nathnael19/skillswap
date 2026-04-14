import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/section_header.dart';

class FeaturedGallerySection extends StatelessWidget {
  const FeaturedGallerySection({super.key});

  static const Color kShadow = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'FEATURED GALLERY',
            title: 'Recent Creations',
            actionLabel: 'View All',
            onActionTap: () {},
            titleColor: Colors.white,
            labelColor: Color(0xFFCA8A04),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
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
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: kShadow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            stops: const [0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

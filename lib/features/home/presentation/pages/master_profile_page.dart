import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/featured_gallery_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_badges_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_header_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_stats_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_sticky_footer.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/reviews_section.dart';

class MasterProfilePage extends StatelessWidget {
  const MasterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF101828), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MASTER PROFILE',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF667085),
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF101828)),
            onPressed: () {},
          ),
        ],
      ),
      body: const Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeaderSection(),
                ProfileStatsSection(),
                ProfileBadgesSection(),
                SizedBox(height: 32),
                FeaturedGallerySection(),
                SizedBox(height: 32),
                ReviewsSection(),
                SizedBox(height: 120), // Padding for sticky footer
              ],
            ),
          ),
          ProfileStickyFooter(),
        ],
      ),
    );
  }
}

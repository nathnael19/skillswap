import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/master_profile_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/featured_gallery_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_badges_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_header_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_stats_section.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/profile_sticky_footer.dart';
import 'package:skillswap/features/home/presentation/widgets/master_profile/reviews_section.dart';
import 'package:skillswap/init_dependencies.dart';

class MasterProfilePage extends StatelessWidget {
  final String userId;
  const MasterProfilePage({super.key, required this.userId});

  // Premium Palette (Updated to match App Theme)
  static const Color kPrimary = Color(0xFFCA8A04);
  static const Color kSecondary = Colors.white;
  static const Color kBackground = Color(0xFF0C0A09);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<MasterProfileCubit>()..fetchProfile(userId),
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: kBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'MASTER PROFILE',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<MasterProfileCubit, MasterProfileState>(
          builder: (context, state) {
            if (state is MasterProfileLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: kPrimary));
            }

            if (state is MasterProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            }

            if (state is MasterProfileLoaded) {
              final user = state.user;
              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderSection(user: user),
                        ProfileStatsSection(user: user),
                        ProfileBadgesSection(user: user),
                        const SizedBox(height: 32),
                        const FeaturedGallerySection(),
                        const SizedBox(height: 32),
                        const ReviewsSection(),
                        const SizedBox(height: 140), // More padding for sticky footer
                      ],
                    ),
                  ),
                  ProfileStickyFooter(user: user),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

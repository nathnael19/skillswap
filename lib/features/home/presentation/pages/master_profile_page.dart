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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<MasterProfileCubit>()..fetchProfile(userId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back, color: Color(0xFF101828), size: 24),
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
        body: BlocBuilder<MasterProfileCubit, MasterProfileState>(
          builder: (context, state) {
            if (state is MasterProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MasterProfileError) {
              return Center(child: Text(state.message));
            }

            if (state is MasterProfileLoaded) {
              final user = state.user;
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderSection(user: user),
                        ProfileStatsSection(user: user),
                        ProfileBadgesSection(user: user),
                        const SizedBox(height: 32),
                        const FeaturedGallerySection(), // Keeping gallery static for now as it needs separate storage logic
                        const SizedBox(height: 32),
                        const ReviewsSection(), // Keeping reviews static as requested previously
                        const SizedBox(height: 120), // Padding for sticky footer
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

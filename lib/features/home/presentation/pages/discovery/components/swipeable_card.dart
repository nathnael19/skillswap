import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile/master_profile_page.dart';
import 'package:skillswap/core/theme/theme.dart';

class SwipeableCard extends StatelessWidget {
  final User user;
  final bool isDraggable;

  const SwipeableCard({super.key, required this.user, this.isDraggable = true});

  @override
  Widget build(BuildContext context) {
    final topInset = Responsive.valueFor<double>(
      context,
      compact: 96,
      mobile: 108,
      tablet: 116,
      tabletWide: 120,
      desktop: 128,
    );
    final edge = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 20,
      tablet: 22,
      tabletWide: 24,
      desktop: 28,
    );
    final bottomPad = Responsive.valueFor<double>(
      context,
      compact: 80,
      mobile: 92,
      tablet: 96,
      tabletWide: 100,
      desktop: 108,
    );
    final nameSize = Responsive.valueFor<double>(
      context,
      compact: 26,
      mobile: 30,
      tablet: 32,
      tabletWide: 34,
      desktop: 36,
    );
    final subtitleSize = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 15,
      tablet: 16,
      tabletWide: 16,
      desktop: 17,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child:
                  user.imageUrl.startsWith('http') ||
                      user.imageUrl.startsWith('/static')
                  ? CachedNetworkImage(
                      imageUrl: user.imageUrl.startsWith('/')
                          ? '${ApiConstants.mediaBaseUrl}${user.imageUrl}'
                          : user.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          Image.asset('assets/home.png', fit: BoxFit.cover),
                    )
                  : Image.asset('assets/home.png', fit: BoxFit.cover),
            ),

            // Seamless bottom vignette for tinder-style legibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),

            // Top gradient scrim for better badge legibility
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Online Badge (Top Right)
            Positioned(
              top: edge,
              right: edge,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.textPrimary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4ADE80),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Online',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // User Info Section (Seamless)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(edge, 0, edge, bottomPad),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MasterProfilePage(userId: user.id),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: GoogleFonts.dmSans(
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (user.age != 0)
                                  Text(
                                    'Expert, ${user.age}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: subtitleSize,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildRatingBadge(user.rating),
                        ],
                      ),
                      SizedBox(height: Responsive.valueFor<double>(context, compact: 14, mobile: 16, tablet: 18, tabletWide: 20, desktop: 20)),
                      () {
                        final isSmall = Responsive.isCompact(context);
                        if (isSmall) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSkillBadge(
                                label: 'Can Teach',
                                skill: user.teaching?.name ?? 'Expertise',
                                isPrimary: true,
                                expand: false,
                              ),
                              const SizedBox(height: 10),
                              _buildSkillBadge(
                                label: 'Wants to Learn',
                                skill: user.learning?.name ?? 'Skills',
                                isPrimary: false,
                                expand: false,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            _buildSkillBadge(
                              label: 'Can Teach',
                              skill: user.teaching?.name ?? 'Expertise',
                              isPrimary: true,
                              expand: true,
                            ),
                            SizedBox(width: Responsive.valueFor<double>(context, compact: 8, mobile: 10, tablet: 12, tabletWide: 12, desktop: 12)),
                            _buildSkillBadge(
                              label: 'Wants to Learn',
                              skill: user.learning?.name ?? 'Skills',
                              isPrimary: false,
                              expand: true,
                            ),
                          ],
                        );
                      }(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.dmSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge({
    required String label,
    required String skill,
    required bool isPrimary,
    bool expand = true,
  }) {
    final accentColor = isPrimary ? AppColors.primary : AppColors.textPrimary;

    final box = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: accentColor.withValues(alpha: 0.5),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              skill,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );

    if (expand) {
      return Expanded(child: box);
    }
    return box;
  }
}

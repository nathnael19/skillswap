import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/core/theme/theme.dart';

class ExpertCard extends StatelessWidget {
  final User user;
  final VoidCallback? onRequestMatch;
  final VoidCallback? onLike;

  const ExpertCard({
    super.key,
    required this.user,
    this.onRequestMatch,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final hMargin = Responsive.contentHorizontalPadding(context);
    final innerPad = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 18,
      tablet: 19,
      tabletWide: 20,
      desktop: 22,
    );
    final avatar = Responsive.valueFor<double>(
      context,
      compact: 60,
      mobile: 66,
      tablet: 72,
      tabletWide: 76,
      desktop: 80,
    );
    final nameSize = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 17,
      tablet: 18,
      tabletWide: 19,
      desktop: 20,
    );
    final bioSize = Responsive.valueFor<double>(
      context,
      compact: 12,
      mobile: 12,
      tablet: 13,
      tabletWide: 13,
      desktop: 14,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.overlay03,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.overlay08, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: EdgeInsets.all(innerPad),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Glass Border
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.overlay10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          user.imageUrl.startsWith('http') ||
                              user.imageUrl.startsWith('/static')
                          ? CachedNetworkImage(
                              imageUrl: user.imageUrl.startsWith('/')
                                  ? '${ApiConstants.mediaBaseUrl}${user.imageUrl}'
                                  : user.imageUrl,
                              width: avatar,
                              height: avatar,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Image.asset(
                                'assets/home.png',
                                width: avatar,
                                height: avatar,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/home.png',
                              width: avatar,
                              height: avatar,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: nameSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            // Glass Rating Badge
                            _buildRatingBadge(user.rating),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (user.teaching?.name ?? 'EXPERT').toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio.isEmpty
                              ? AppConstants.defaultBio
                              : user.bio,
                          style: GoogleFonts.dmSans(
                            fontSize: bioSize,
                            fontWeight: FontWeight.w400,
                            color: AppColors.overlay50,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Actions
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 340;
                  return Row(
                    children: [
                  Expanded(
                    flex: narrow ? 1 : 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onRequestMatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textPrimary,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.valueFor<double>(
                              context,
                              compact: 12,
                              mobile: 13,
                              tablet: 14,
                              tabletWide: 14,
                              desktop: 15,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Request Match',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.valueFor<double>(
                              context,
                              compact: 12,
                              mobile: 13,
                              tablet: 14,
                              tabletWide: 14,
                              desktop: 15,
                            ),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.valueFor<double>(context, compact: 8, mobile: 10, tablet: 12, tabletWide: 12, desktop: 12)),
                  _buildLikeButton(context),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    final likeIcon = Responsive.valueFor<double>(
      context,
      compact: 18,
      mobile: 19,
      tablet: 20,
      tabletWide: 20,
      desktop: 22,
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.overlay05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.overlay10),
      ),
      child: IconButton(
        onPressed: onLike,
        icon: Icon(
          Icons.favorite_outline_rounded,
          color: AppColors.textPrimary,
          size: likeIcon,
        ),
        style: IconButton.styleFrom(
          padding: EdgeInsets.all(Responsive.valueFor<double>(
            context,
            compact: 8,
            mobile: 10,
            tablet: 11,
            tabletWide: 12,
            desktop: 12,
          )),
        ),
      ),
    );
  }
}

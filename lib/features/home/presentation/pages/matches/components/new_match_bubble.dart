import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/core/theme/theme.dart';

class NewMatchBubble extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String teachingSkill;
  final bool isTopMatch;
  final VoidCallback onTap;

  const NewMatchBubble({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.teachingSkill,
    this.isTopMatch = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Luxury Halo
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: imageUrl.startsWith('assets')
                            ? Image.asset(
                                imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/home.png',
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (isTopMatch)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppColors.textPrimary,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),
            Text(
              teachingSkill.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

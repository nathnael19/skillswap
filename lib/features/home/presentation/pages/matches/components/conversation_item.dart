import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/network/api_constants.dart';

class ConversationItem extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String lastMessage;
  final String timestamp;
  final String skillTag;
  final bool isOnline;
  final bool hasUnread;
  final bool isPaidPending;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.skillTag,
    this.isOnline = false,
    this.hasUnread = false,
    this.isPaidPending = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    final avatar = Responsive.valueFor<double>(
      context,
      compact: 46,
      mobile: 50,
      tablet: 52,
      tabletWide: 54,
      desktop: 56,
    );
    final pad = Responsive.valueFor<double>(
      context,
      compact: 14,
      mobile: 16,
      tablet: 17,
      tabletWide: 18,
      desktop: 18,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: Responsive.valueFor<double>(
            context,
            compact: 8,
            mobile: 10,
            tablet: 11,
            tabletWide: 12,
            desktop: 12,
          ),
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),

        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                // Premium Avatar
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: userImageUrl.startsWith('assets')
                            ? Image.asset(
                                userImageUrl,
                                width: avatar,
                                height: avatar,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: userImageUrl.startsWith('/')
                                    ? '${ApiConstants.mediaBaseUrl}$userImageUrl'
                                    : userImageUrl,
                                width: avatar,
                                height: avatar,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/home.png',
                                      width: avatar,
                                      height: avatar,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 18),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Text(
                            timestamp,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: hasUnread
                              ? accentColor
                              : AppColors.textSecondary,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              skillTag,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: accentColor,
                              ),
                            ),
                          ),
                          if (isPaidPending) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.googleBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(100),

                                border: Border.all(
                                  color: AppColors.googleBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Direct Message",
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.googleBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

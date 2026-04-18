import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/services/presence_service.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeaderSection extends StatelessWidget {
  final User user;
  const ProfileHeaderSection({super.key, required this.user});

  static const Color kPrimary = AppColors.primary;
  static const Color kSecondary = AppColors.textPrimary;
  static const Color kTextMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 130,
                height: 130,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: kPrimary.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: (user.imageUrl.startsWith('http') || user.imageUrl.startsWith('/static'))
                              ? CachedNetworkImageProvider(
                                  user.imageUrl.startsWith('/')
                                      ? '${ApiConstants.mediaBaseUrl}${user.imageUrl}'
                                      : user.imageUrl,
                                )
                              : AssetImage(
                                  user.imageUrl.isEmpty
                                      ? 'assets/home.png'
                                      : user.imageUrl,
                                ) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15), // Gold
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF854D0E),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                user.profession,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Expert',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: kPrimary,
                  ),
                ),
              ),
              const Spacer(),
              StreamBuilder<bool>(
                stream: PresenceService.instance.watchPresence(user.id),
                builder: (context, snapshot) {
                  final isOnline = snapshot.data ?? false;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : AppColors.overlay05,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOnline
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : AppColors.overlay10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFF10B981)
                                : AppColors.textPrimary.withValues(alpha: 0.38),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online now' : 'Offline',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isOnline
                                ? const Color(0xFF10B981)
                                : AppColors.textPrimary.withValues(alpha: 0.38),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: kSecondary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.bio.isEmpty
                ? "Interested in swapping skills and growing together."
                : user.bio,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: kTextMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

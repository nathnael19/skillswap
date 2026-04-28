import 'package:flutter/material.dart';
import 'package:skillswap/core/common/widgets/user_avatar.dart';
import 'package:skillswap/core/theme/theme.dart';

class AvatarHeader extends StatelessWidget {
  final String peerName;
  final String peerImageUrl;

  const AvatarHeader({
    super.key,
    required this.peerName,
    required this.peerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: UserAvatar(
                  imageUrl: peerImageUrl,
                  radius: 50,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF9E6400),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Skill Exchange Complete',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Review your session\nwith $peerName',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

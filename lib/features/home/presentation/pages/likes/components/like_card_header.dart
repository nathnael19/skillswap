import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile/master_profile_page.dart';
import 'package:skillswap/core/theme/theme.dart';

class LikeCardHeader extends StatelessWidget {
  final User user;

  const LikeCardHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MasterProfilePage(userId: user.id),
          ),
        );
      },
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.7, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.darken,
            child: user.imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    user.imageUrl.isEmpty ? 'assets/home.png' : user.imageUrl,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          // Premium Overlay Metadata
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    user.teaching?.name ?? 'Expert',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('${user.name}, ${user.age}', style: AppTextStyles.h2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

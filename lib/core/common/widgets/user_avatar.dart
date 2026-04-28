import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:skillswap/core/cache/app_image_cache_manager.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/core/theme/theme.dart';

/// A circular avatar with an optional online status dot.
/// Used in MatchesPage, ChatPage, and anywhere user presence is shown.
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool showOnlineDot;
  final bool isOnline;
  final double dotSize;
  final BorderRadius? borderRadius;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 30,
    this.showOnlineDot = false,
    this.isOnline = false,
    this.dotSize = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork =
        imageUrl.startsWith('http') || imageUrl.startsWith('/static');
    final String fullImageUrl = imageUrl.startsWith('/')
        ? '${ApiConstants.mediaBaseUrl}$imageUrl'
        : imageUrl;

    final Widget imageWidget = isNetwork
        ? CachedNetworkImage(
            imageUrl: fullImageUrl,
            cacheManager: AppImageCacheManager.instance,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => Image.asset(
              'assets/home.png',
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imageUrl.isEmpty ? 'assets/home.png' : imageUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          );

    final Widget avatar = borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: imageWidget)
        : ClipOval(child: imageWidget);

    if (!showOnlineDot) return avatar;

    return Stack(
      children: [
        avatar,
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: const Color(0xFF12B76A),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

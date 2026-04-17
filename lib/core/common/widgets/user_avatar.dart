import 'package:flutter/material.dart';

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
    final Widget avatar = borderRadius != null
        ? ClipRRect(
            borderRadius: borderRadius!,
            child: Image.asset(
              imageUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: AssetImage(imageUrl),
          );

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
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

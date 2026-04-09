import 'dart:ui';
import 'package:flutter/material.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onChat;
  final bool enabled;

  const SwipeActionButtons({
    super.key,
    required this.onLike,
    required this.onDislike,
    required this.onChat,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            icon: Icons.close,
            color: Colors.white.withOpacity(0.2), // Glass effect
            iconColor: Colors.white,
            onTap: onDislike,
            enabled: enabled,
            isGlass: true,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            icon: Icons.favorite,
            color: const Color(0xFF9E6400), // Rich brown/orange
            iconColor: Colors.white,
            size: 84,
            iconSize: 34,
            hasShadow: true,
            onTap: onLike,
            enabled: enabled,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.white.withOpacity(0.2), // Glass effect
            iconColor: Colors.white,
            onTap: onChat,
            enabled: enabled,
            isGlass: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    double size = 56,
    double iconSize = 24,
    bool hasShadow = false,
    VoidCallback? onTap,
    bool enabled = true,
    bool isGlass = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isGlass ? 10 : 0,
            sigmaY: isGlass ? 10 : 0,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: enabled ? color : color.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: hasShadow && enabled
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
              border: isGlass
                  ? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)
                  : null,
            ),
            child: Icon(
              icon,
              color: enabled ? iconColor : iconColor.withOpacity(0.5),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

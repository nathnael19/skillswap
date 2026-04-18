import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/theme.dart';

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
          _buildGlassButton(
            icon: Icons.close_rounded,
            onTap: onDislike,
            enabled: enabled,
            size: 64,
          ),
          const SizedBox(width: 24),
          _buildPrimaryButton(
            icon: Icons.favorite_rounded,
            onTap: onLike,
            enabled: enabled,
            size: 88,
          ),
          const SizedBox(width: 24),
          _buildGlassButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onChat,
            enabled: enabled,
            size: 64,
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required double size,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary, // Premium Gold
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: size * 0.4),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required double size,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.overlay10,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.overlay20, width: 1.5),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: size * 0.4),
          ),
        ),
      ),
    );
  }
}

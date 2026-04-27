import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

class LiveSessionControls extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleVideo;
  final Future<bool?> Function() onEndCallRequest;

  const LiveSessionControls({
    super.key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.onToggleMic,
    required this.onToggleVideo,
    required this.onEndCallRequest,
  });

  static const Color accentColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    final side = Responsive.contentHorizontalPadding(context)
        .clamp(12.0, 28.0)
        .toDouble();
    final bottom = Responsive.valueFor<double>(
          context,
          compact: 20,
          mobile: 28,
          tablet: 32,
          tabletWide: 36,
          desktop: 40,
        ) +
        inset;
    final barH = Responsive.valueFor<double>(
      context,
      compact: 72,
      mobile: 80,
      tablet: 84,
      tabletWide: 88,
      desktop: 92,
    );
    final btn = Responsive.valueFor<double>(
      context,
      compact: 46,
      mobile: 50,
      tablet: 52,
      tabletWide: 52,
      desktop: 56,
    );
    final iconSz = Responsive.valueFor<double>(
      context,
      compact: 22,
      mobile: 24,
      tablet: 25,
      tabletWide: 26,
      desktop: 28,
    );
    return Positioned(
      bottom: bottom,
      left: side,
      right: side,
      child: Container(
        height: barH,
        decoration: BoxDecoration(
          color: AppColors.overlay08,
          borderRadius: BorderRadius.circular(barH * 0.5),
          border: Border.all(color: AppColors.overlay10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(barH * 0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  isMuted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
                  isActive: !isMuted,
                  onTap: onToggleMic,
                  accentColor: accentColor,
                  size: btn,
                  iconSize: iconSz,
                ),
                _buildControlButton(
                  isVideoEnabled
                      ? Icons.videocam_outlined
                      : Icons.videocam_off_outlined,
                  isActive: isVideoEnabled,
                  onTap: onToggleVideo,
                  accentColor: accentColor,
                  size: btn,
                  iconSize: iconSz,
                ),
                _buildEndCallButton(context, btn, iconSz),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
    required Color accentColor,
    required double size,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.1)
              : AppColors.overlay05,
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: accentColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? accentColor : AppColors.textPrimary,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildEndCallButton(
    BuildContext context,
    double size,
    double iconSize,
  ) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text(
              'End Session?',
              style: GoogleFonts.dmSans(color: AppColors.textPrimary),
            ),
            content: Text(
              'This will complete the session and settle credits.',
              style: GoogleFonts.dmSans(color: AppColors.textPrimary.withValues(alpha: 0.70)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary.withValues(alpha: 0.54)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'End Session',
                  style: GoogleFonts.dmSans(color: AppColors.error),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await onEndCallRequest();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.call_end_rounded,
          color: AppColors.textPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}

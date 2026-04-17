import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const Color accentColor = Color(0xFFCA8A04);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
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
                ),
                _buildControlButton(
                  isVideoEnabled
                      ? Icons.videocam_outlined
                      : Icons.videocam_off_outlined,
                  isActive: isVideoEnabled,
                  onTap: onToggleVideo,
                  accentColor: accentColor,
                ),
                _buildEndCallButton(context),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: accentColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? accentColor : Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0C0A09),
            title: Text(
              'End Session?',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            content: Text(
              'This will complete the session and settle credits.',
              style: GoogleFonts.dmSans(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'End Session',
                  style: GoogleFonts.dmSans(color: const Color(0xFFEF4444)),
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
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

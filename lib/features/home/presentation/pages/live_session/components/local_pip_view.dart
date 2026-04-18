import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:skillswap/core/theme/theme.dart';

class LocalPiPView extends StatelessWidget {
  final bool isInitialized;
  final bool isVideoEnabled;
  final RTCVideoRenderer localRenderer;

  const LocalPiPView({
    super.key,
    required this.isInitialized,
    required this.isVideoEnabled,
    required this.localRenderer,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140,
      right: 20,
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.overlay20, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.5),
          child: isInitialized && isVideoEnabled
              ? RTCVideoView(
                  localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Center(
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: AppColors.textPrimary.withValues(alpha: 0.54),
                  ),
                ),
        ),
      ),
    );
  }
}

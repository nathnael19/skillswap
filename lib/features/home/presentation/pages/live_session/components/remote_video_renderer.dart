import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:skillswap/core/theme/theme.dart';

class RemoteVideoRenderer extends StatelessWidget {
  final bool isInitialized;
  final RTCVideoRenderer remoteRenderer;
  final Color backgroundColor;

  const RemoteVideoRenderer({
    super.key,
    required this.isInitialized,
    required this.remoteRenderer,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitialized && remoteRenderer.srcObject != null) {
      return RTCVideoView(
        remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    }

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_tethering_rounded,
              color: AppColors.textPrimary.withValues(alpha: 0.24),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for expert...',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.overlay30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

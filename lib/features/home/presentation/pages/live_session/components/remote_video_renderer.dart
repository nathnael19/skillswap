import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';

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
            const Icon(
              Icons.wifi_tethering_rounded,
              color: Colors.white24,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for expert...',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

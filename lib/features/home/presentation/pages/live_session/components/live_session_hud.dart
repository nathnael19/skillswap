import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveSessionHud extends StatelessWidget {
  final String peerName;
  final ValueNotifier<int> secondsElapsed;
  final Animation<double> pulseAnimation;

  const LiveSessionHud({
    super.key,
    required this.peerName,
    required this.secondsElapsed,
    required this.pulseAnimation,
  });

  static const Color accentColor = Color(0xFFCA8A04);

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Session',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    peerName,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildRecordingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: pulseAnimation,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<int>(
            valueListenable: secondsElapsed,
            builder: (context, seconds, _) {
              return Text(
                _formatDuration(seconds),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

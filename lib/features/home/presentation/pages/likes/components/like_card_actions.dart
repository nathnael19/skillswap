import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LikeCardActions extends StatelessWidget {
  final bool isReceived;
  final bool isSent;
  final bool isPassed;
  final VoidCallback onProfileTap;
  final VoidCallback onConnectTap;
  final VoidCallback onWithdrawTap;

  const LikeCardActions({
    super.key,
    required this.isReceived,
    required this.isSent,
    required this.isPassed,
    required this.onProfileTap,
    required this.onConnectTap,
    required this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Center(
                child: Text(
                  'Profile',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isReceived || isSent || isPassed) const SizedBox(width: 14),
        if (isReceived || isPassed)
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentColor, Color(0xFFB47B03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: -2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onConnectTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isPassed ? 'Connect' : 'Connect',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        if (isSent)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onWithdrawTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Withdraw',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

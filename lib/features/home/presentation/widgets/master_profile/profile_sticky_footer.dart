import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStickyFooter extends StatelessWidget {
  const ProfileStickyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B6A7A),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0B6A7A).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Request Swap',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: Color(0xFF0B6A7A)),
            ),
          ],
        ),
      ),
    );
  }
}

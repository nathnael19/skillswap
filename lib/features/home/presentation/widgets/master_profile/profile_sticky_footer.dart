import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

class ProfileStickyFooter extends StatelessWidget {
  final User user;
  const ProfileStickyFooter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFFCA8A04);
    const kBackground = Color(0xFF1C1917);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Request Swap',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: const Icon(Icons.chat_bubble_rounded,
                    color: kPrimary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyDiscoveryState extends StatelessWidget {
  const EmptyDiscoveryState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCA8A04).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFCA8A04),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "You're all caught up!",
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You've seen everyone for now. Check back later for new people to connect with.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

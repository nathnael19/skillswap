import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchesEmptyState extends StatelessWidget {
  const MatchesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 56,
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "No connections yet",
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Explore experts and start chatting to share skills.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.3),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

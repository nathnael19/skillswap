import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyPortfolioState extends StatelessWidget {
  const EmptyPortfolioState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your best work to show off your skills.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

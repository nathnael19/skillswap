import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildStatCard('RATING', '4.98', '/ 5'),
          const SizedBox(width: 12),
          _buildStatCard('SWAPS', '142', ''),
          const SizedBox(width: 12),
          _buildStatCard('RESPONSE', 'Instant', ''),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String suffix) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF667085),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B6A7A),
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: suffix,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

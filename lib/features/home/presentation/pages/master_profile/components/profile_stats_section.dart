import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/theme/theme.dart';

class ProfileStatsSection extends StatelessWidget {
  final User user;
  const ProfileStatsSection({super.key, required this.user});

  static const Color kPrimary = AppColors.primary;
  static const Color kSecondary = AppColors.textPrimary;
  static const Color kTextMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildStatCard('Rating', user.rating.toStringAsFixed(1), '/ 5'),
          const SizedBox(width: 12),
          _buildStatCard('Swaps', '24', ''), // Placeholder for real swap count
          const SizedBox(width: 12),
          _buildStatCard(
            'Response',
            'Fast',
            '',
          ), // Placeholder for response time
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String suffix) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.overlay05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kPrimary.withValues(alpha: 0.8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: suffix,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextMuted.withValues(alpha: 0.4),
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

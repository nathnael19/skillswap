import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';
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
    final hPad = Responsive.contentHorizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = 12.0;
          final cardW = ((c.maxWidth - gap * 2) / 3).clamp(88.0, 200.0);
          return Row(
            children: [
              SizedBox(
                width: cardW,
                child: _buildStatCard(
                  'Rating',
                  user.rating.toStringAsFixed(1),
                  '/ 5',
                ),
              ),
              const SizedBox(width: gap),
              SizedBox(width: cardW, child: _buildStatCard('Swaps', '24', '')),
              const SizedBox(width: gap),
              SizedBox(
                width: cardW,
                child: _buildStatCard('Response', 'Fast', ''),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String suffix) {
    return Container(
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
    );
  }
}

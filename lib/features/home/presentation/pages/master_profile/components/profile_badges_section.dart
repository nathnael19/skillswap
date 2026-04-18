import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/core/theme/theme.dart';

class ProfileBadgesSection extends StatelessWidget {
  final User user;
  const ProfileBadgesSection({super.key, required this.user});

  static const Color kPrimary = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          // Identity Check
          _buildBadge(
            Icons.verified_user_rounded,
            'Identity Verified',
            kPrimary.withValues(alpha: 0.1),
            kPrimary,
          ),

          // Teaching Skill
          if (user.teaching != null)
            _buildBadge(
              Icons.school_rounded,
              'Teaches ${user.teaching!.name}',
              kPrimary.withValues(alpha: 0.1),
              kPrimary,
            ),

          // Learning Skill
          if (user.learning != null)
            _buildBadge(
              Icons.auto_awesome_rounded,
              'Learning ${user.learning!.name}',
              AppColors.overlay05,
              AppColors.overlay70,
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

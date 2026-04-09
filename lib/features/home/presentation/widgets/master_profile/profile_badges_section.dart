import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildBadge(Icons.verified_user_outlined, 'Identity Verified',
              const Color(0xFFF0F9FF), const Color(0xFF026AA2)),
          _buildBadge(Icons.workspace_premium_outlined, 'Top Swapper \'23',
              const Color(0xFFFEF6EE), const Color(0xFFB93815)),
          _buildBadge(Icons.palette_outlined, 'Figma Pro',
              const Color(0xFFF9FAFB), const Color(0xFF475467)),
        ],
      ),
    );
  }

  Widget _buildBadge(
      IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

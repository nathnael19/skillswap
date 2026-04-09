import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable two-line section header: a small uppercase label + a large title.
/// Used consistently across profile, schedule, wallet, and other pages.
class SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Color labelColor;
  final Color titleColor;
  final double titleFontSize;

  const SectionHeader({
    super.key,
    required this.label,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.labelColor = const Color(0xFF98A2B3),
    this.titleColor = const Color(0xFF101828),
    this.titleFontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: labelColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B6A7A),
              ),
            ),
          ),
      ],
    );
  }
}

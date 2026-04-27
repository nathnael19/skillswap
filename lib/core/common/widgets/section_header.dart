import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/layout/responsive.dart';

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
    final resolvedTitleSize = Responsive.valueFor<double>(
      context,
      compact: (titleFontSize - 4).clamp(16, titleFontSize),
      mobile: titleFontSize,
      tablet: titleFontSize + 2,
      tabletWide: titleFontSize + 2,
      desktop: titleFontSize + 4,
    );
    final actionSize = Responsive.valueFor<double>(
      context,
      compact: 12,
      mobile: 13,
      tablet: 14,
      tabletWide: 14,
      desktop: 15,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: Responsive.valueFor<double>(
                    context,
                    compact: 9,
                    mobile: 10,
                    tablet: 10,
                    tabletWide: 10,
                    desktop: 11,
                  ),
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: resolvedTitleSize,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionLabel!,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: actionSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B6A7A),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

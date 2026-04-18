import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/theme/theme.dart';

class EndorsementsSection extends StatelessWidget {
  final List<String> endorsementOptions;
  final Set<String> selectedEndorsements;
  final Function(String) onToggle;

  const EndorsementsSection({
    super.key,
    required this.endorsementOptions,
    required this.selectedEndorsements,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Endorsements',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475467),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: endorsementOptions.map((trait) {
            bool isSelected = selectedEndorsements.contains(trait);
            return GestureDetector(
              onTap: () => onToggle(trait),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0B6A7A)
                      : const Color(0xFFE4E7EC).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trait,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : const Color(0xFF475467),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

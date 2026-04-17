import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpertiseSegmentedControl extends StatelessWidget {
  final List<String> expertiseLevels;
  final String selectedExpertise;
  final Function(String) onSelect;

  const ExpertiseSegmentedControl({
    super.key,
    required this.expertiseLevels,
    required this.selectedExpertise,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: expertiseLevels.map((level) {
          final isSelected = selectedExpertise == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(level),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFCA8A04) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFCA8A04).withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

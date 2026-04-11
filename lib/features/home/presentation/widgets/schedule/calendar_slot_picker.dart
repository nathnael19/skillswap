import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarSlotPicker extends StatelessWidget {
  const CalendarSlotPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAECF5).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B6A7A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                '1. Choose Your Slot',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left, color: Color(0xFF667085)),
                    Text(
                      'October 2023',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF667085)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCalendarGrid(context),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTimeChip('09:00 AM', false),
                    const SizedBox(width: 8),
                    _buildTimeChip('10:30 AM', true),
                    const SizedBox(width: 8),
                    _buildTimeChip('02:00 PM', false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final dates = [
      '28', '29', '30', '1', '2', '3', '4',
      '5', '6', '7', '8', '9', '', ''
    ];

    // Replacing the window size access with MediaQuery.of(context)
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days
              .map((d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF98A2B3),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: (width - 48 - 80 - 224) / 6,
          runSpacing: 12,
          children: List.generate(12, (index) {
            String date = dates[index];
            bool isPast = index < 3;
            bool isSelected = date == '5';

            return Container(
              width: 32,
              height: 32,
              decoration: isSelected
                  ? const BoxDecoration(
                      color: Color(0xFF0B6A7A),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isPast
                            ? const Color(0xFFD0D5DD)
                            : const Color(0xFF101828)),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label, bool isSelected) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B6A7A) : const Color(0xFFEAECF5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF475467),
            ),
          ),
        ),
      ),
    );
  }
}

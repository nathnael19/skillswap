import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarSlotPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;

  const CalendarSlotPicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: accentColor, size: 22),
              ),
              const SizedBox(width: 20),
              Text(
                '1. TEMPORAL SLOT',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Calendar Grid
          _buildPremiumCalendar(context),
          const SizedBox(height: 48),
          // Time Slots
          Row(
            children: [
              _buildTimeChip('09:00 AM'),
              const SizedBox(width: 12),
              _buildTimeChip('10:30 AM'),
              const SizedBox(width: 12),
              _buildTimeChip('02:00 PM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCalendar(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const accentColor = Color(0xFFCA8A04);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left_rounded, color: Colors.white24),
            Text(
              'OCTOBER 2026',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 2.0,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days
              .map((d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: (MediaQuery.of(context).size.width - 150 - 224) / 6,
          runSpacing: 16,
          children: List.generate(14, (index) {
            int dateValue = index + 1;
            bool isPast = dateValue < 12;
            bool isSelected = selectedDate?.day == dateValue;

            return GestureDetector(
              onTap: isPast ? null : () => onDateSelected(DateTime(2026, 10, dateValue)),
              child: Container(
                width: 32,
                height: 32,
                decoration: isSelected
                    ? BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                          )
                        ],
                      )
                    : null,
                child: Center(
                  child: Text(
                    dateValue.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isPast
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label) {
    bool isSelected = selectedTime == label;
    const accentColor = Color(0xFFCA8A04);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTimeSelected(label),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/core/theme/theme.dart';

class CalendarSlotPicker extends StatefulWidget {
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
  State<CalendarSlotPicker> createState() => _CalendarSlotPickerState();
}

class _CalendarSlotPickerState extends State<CalendarSlotPicker> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.selectedDate ?? DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  List<DateTime> _generateDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    final days = <DateTime>[];
    // Add padding for the start of the week
    final weekdayOfFirst = firstDay.weekday % 7; // 0 for Sunday
    for (var i = 0; i < weekdayOfFirst; i++) {
      days.add(firstDay.subtract(Duration(days: weekdayOfFirst - i)));
    }
    
    for (var i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.overlay03,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.overlay08),
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
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '1. Choose a Time',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildPremiumCalendar(context),
          const SizedBox(height: 40),
          _buildTimeSlots(),
        ],
      ),
    );
  }

  Widget _buildPremiumCalendar(BuildContext context) {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const accentColor = AppColors.primary;
    final monthName = DateFormat('MMMM yyyy').format(_focusedMonth);
    final days = _generateDays();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _previousMonth,
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            Text(
              monthName.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.overlay60,
                letterSpacing: 2.0,
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays
              .map(
                (d) => SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isCurrentMonth = date.month == _focusedMonth.month;
            final isSelected = widget.selectedDate != null &&
                date.year == widget.selectedDate!.year &&
                date.month == widget.selectedDate!.month &&
                date.day == widget.selectedDate!.day;
            
            final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

            if (!isCurrentMonth) return const SizedBox.shrink();

            return GestureDetector(
              onTap: isPast ? null : () => widget.onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: isSelected
                    ? BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      )
                    : null,
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.textPrimary
                          : (isPast
                              ? AppColors.overlay10
                              : AppColors.textPrimary.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    final times = [
      '09:00 AM',
      '10:30 AM',
      '12:00 PM',
      '02:00 PM',
      '04:30 PM',
      '07:00 PM',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: times.map((time) {
          final isSelected = widget.selectedTime == time;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => widget.onTimeSelected(time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.overlay05,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.overlay10,
                  ),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.overlay60,
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

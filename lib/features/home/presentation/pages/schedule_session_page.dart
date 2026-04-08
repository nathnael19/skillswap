import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/live_session_page.dart';

class ScheduleSessionPage extends StatelessWidget {
  const ScheduleSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEAECF5)),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF101828), size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          'Schedule Session',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildProgressHeader(),
            const SizedBox(height: 40),
            _buildChooseSlot(),
            const SizedBox(height: 32),
            _buildTeachingPoints(),
            const SizedBox(height: 32),
            _buildMeetingHub(),
            const SizedBox(height: 40),
            _buildConfirmButton(context),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'BY CONFIRMING, BOTH USERS AGREE TO THE SKILLSWAP\nCODE OF CONDUCT',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF98A2B3),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION SETUP',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B6A7A),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Agreement & Logistics',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475467),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '2',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B6A7A),
                  ),
                ),
                Text(
                  ' / 3',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFEAECF5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: 2 / 3,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B6A7A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '“Almost ready to swap!”',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF0B6A7A),
          ),
        ),
      ],
    );
  }

  Widget _buildChooseSlot() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAECF5).withOpacity(0.3),
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
                child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 24),
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
                _buildCalendarGrid(),
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

  Widget _buildCalendarGrid() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final dates = [
      '28', '29', '30', '1', '2', '3', '4',
      '5', '6', '7', '8', '9', '', ''
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) => SizedBox(
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
          )).toList(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 48 - 80 - 224) / 6,
          runSpacing: 12,
          children: List.generate(12, (index) {
            String date = dates[index];
            bool isPast = index < 3;
            bool isSelected = date == '5';

            return Container(
              width: 32,
              height: 32,
              decoration: isSelected ? const BoxDecoration(
                color: Color(0xFF0B6A7A),
                shape: BoxShape.circle,
              ) : null,
              child: Center(
                child: Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected 
                      ? Colors.white 
                      : (isPast ? const Color(0xFFD0D5DD) : const Color(0xFF101828)),
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

  Widget _buildTeachingPoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF9E6400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              '2. Teaching Points',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildPointCard(
          title: 'MARCUS WILL TEACH',
          topic: 'Intro to Figma Components',
          desc: 'Mastering auto-layout and variants for responsive web design.',
          isDone: true,
        ),
        const SizedBox(height: 16),
        _buildPointCard(
          title: 'YOU WILL TEACH',
          topic: 'Basic Tailwind Layouts',
          desc: 'Waiting for Marcus to confirm your proposed topics...',
          isDone: false,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD0D5DD), width: 1.5, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: Color(0xFF667085), size: 20),
              const SizedBox(width: 10),
              Text(
                'SUGGEST TEACHING POINT',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF667085),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointCard({
    required String title,
    required String topic,
    required String desc,
    required bool isDone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF9E6400).withOpacity(0.1) : const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.more_horiz_rounded,
                  color: isDone ? const Color(0xFF9E6400) : const Color(0xFF0B6A7A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF98A2B3),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF667085),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isDone)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B6A7A),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingHub() {
    return Column(
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
              child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              '3. Meeting Hub',
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAECF5).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/home.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Creative Collective',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2.4 miles away • Virtual\nbackup available',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF667085),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEAECF5)),
                ),
                child: const Icon(Icons.map_outlined, color: Color(0xFF0B6A7A), size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveSessionPage()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0B6A7A),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B6A7A).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Confirm Session',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

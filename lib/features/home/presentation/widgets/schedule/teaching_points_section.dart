import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeachingPointsSection extends StatelessWidget {
  const TeachingPointsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.list_alt_rounded,
                  color: Colors.white, size: 24),
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
            border: Border.all(
                color: const Color(0xFFD0D5DD),
                width: 1.5,
                style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline,
                  color: Color(0xFF667085), size: 20),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
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
                  color: isDone
                      ? const Color(0xFF9E6400).withOpacity(0.1)
                      : const Color(0xFFE0F2F1),
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
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(24)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeetingHubSection extends StatelessWidget {
  const MeetingHubSection({super.key});

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
                color: const Color(0xFF0B6A7A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_outlined,
                  color: Colors.white, size: 24),
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
            color: const Color(0xFFEAECF5).withValues(alpha: 0.5),
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
                child: const Icon(Icons.map_outlined,
                    color: Color(0xFF0B6A7A), size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

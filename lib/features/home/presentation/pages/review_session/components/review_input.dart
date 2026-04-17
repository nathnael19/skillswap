import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewInput extends StatelessWidget {
  final TextEditingController controller;

  const ReviewInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you learn?',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475467),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4E7EC).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF101828),
            ),
            decoration: InputDecoration(
              hintText:
                  'Sarah was incredibly patient while explaining the fundamentals of Figma auto-layout...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF98A2B3),
                height: 1.4,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

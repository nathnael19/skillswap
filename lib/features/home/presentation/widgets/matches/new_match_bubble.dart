import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMatchBubble extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String teachingSkill;
  final bool isTopMatch;
  final VoidCallback onTap;

  const NewMatchBubble({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.teachingSkill,
    this.isTopMatch = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTopMatch
                          ? const Color(0xFF9E6400) // Gold
                          : const Color(0xFF0B6A7A).withOpacity(0.5), // Teal
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: imageUrl.startsWith('assets')
                        ? Image.asset(
                            imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/home.png',
                                    width: 72, height: 72, fit: BoxFit.cover),
                          ),
                  ),
                ),
                if (isTopMatch)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9E6400),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            Text(
              teachingSkill.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667085),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

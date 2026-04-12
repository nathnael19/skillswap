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
    const accentColor = Color(0xFFCA8A04);
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Luxury Halo
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCA8A04), Color(0xFFB47B03), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C0A09),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
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
                  ),
                ),
                if (isTopMatch)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFCA8A04), Color(0xFFB47B03)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0C0A09), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              teachingSkill.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

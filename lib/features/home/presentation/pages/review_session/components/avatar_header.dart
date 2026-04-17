import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarHeader extends StatelessWidget {
  final String peerName;
  final String peerImageUrl;

  const AvatarHeader({
    super.key,
    required this.peerName,
    required this.peerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(peerImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF9E6400),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars, color: Colors.white, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Skill Exchange Complete',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B6A7A),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your session\nwith $peerName',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarEditorSection extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const AvatarEditorSection({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  static const Color kBackground = Color(0xFF0C0A09);
  static const Color kAccent = Color(0xFFCA8A04);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kAccent.withValues(alpha: 0.2), width: 1),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageUrl.startsWith('http')
                          ? NetworkImage(imageUrl) as ImageProvider
                          : AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBackground, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Change Photo',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: kAccent,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

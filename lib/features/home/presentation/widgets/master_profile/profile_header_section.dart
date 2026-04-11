import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

class ProfileHeaderSection extends StatelessWidget {
  final User user;
  const ProfileHeaderSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: DecorationImage(
                        image: user.imageUrl.startsWith('http')
                            ? NetworkImage(user.imageUrl)
                            : AssetImage(user.imageUrl.isEmpty
                                    ? 'assets/home.png'
                                    : user.imageUrl)
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E6400),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.stars, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.profession.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B6A7A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.name,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.bio.isEmpty
                ? "Interested in swapping skills and growing together."
                : user.bio,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF475467),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

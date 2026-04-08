import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_data.dart';
import '../../domain/models/user_model.dart';

class LikesView extends StatelessWidget {
  const LikesView({super.key});

  @override
  Widget build(BuildContext context) {
    // We'll use the same pool of mock users to represent interest shown
    final likes = [
      mockUsers[2], // Sarah
      mockUsers[1], // Marcus
      mockUsers[0], // Elena
      mockUsers[3], // Let's use David or another mock
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        ...likes.map((user) => _buildLikeCard(context, user)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURATION',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B6A7A),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Interest shown to\nyou',
          style: GoogleFonts.outfit(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF101828),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Discover talented individuals who are interested in your skills. Swap knowledge and grow your craft together.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF667085),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLikeCard(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: Image.asset(
                  user.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Skill Tag overlay
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECDA), // Light peach
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.teaching.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E6400),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${user.name}, ${user.age}',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF0B6A7A)),
                    const SizedBox(width: 4),
                    Text(
                      '2 miles away',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user.bio.isEmpty ? "Passionate about crafting digital experiences that feel human. Looking to swap design systems knowledge for advanced React tips." : user.bio,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'See Profile',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B6A7A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B6A7A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Like Back',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

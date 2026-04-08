import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_data.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('NEW MATCHES • SUCCESS'),
        const SizedBox(height: 16),
        _buildNewMatchesList(),
        const SizedBox(height: 32),
        _buildSectionHeader('CONVERSATIONS • ACTIVE'),
        const SizedBox(height: 16),
        Expanded(
          child: _buildConversationsList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0B6A7A), // Our tealColor
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNewMatchesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: newMatches.map((user) {
          final isTopMatch = user.name == 'Alex'; // For mockup fidelity
          return Padding(
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
                        child: Image.asset(
                          user.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
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
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101828),
                  ),
                ),
                Text(
                  user.teaching.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF667085),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockConversations.length,
      itemBuilder: (context, index) {
        final conv = mockConversations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with Online Status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      conv.user.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (conv.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34A853), // Modern green
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conv.user.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        Text(
                          conv.timestamp,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: conv.hasUnread 
                          ? const Color(0xFF0B6A7A) // Teal for unread
                          : const Color(0xFF667085),
                        fontWeight: conv.hasUnread ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1), // Light teal
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        conv.skillTag,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00796B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (conv.hasUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B6A7A),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

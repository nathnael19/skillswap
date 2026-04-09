import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/chat_page.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/conversation_item.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/new_match_bubble.dart';
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
        _buildNewMatchesList(context),
        const SizedBox(height: 32),
        _buildSectionHeader('CONVERSATIONS • ACTIVE'),
        const SizedBox(height: 16),
        Expanded(
          child: _buildConversationsList(context),
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
          color: const Color(0xFF0B6A7A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNewMatchesList(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: newMatches.map((user) {
          final isTopMatch = user.name == 'Alex';
          return NewMatchBubble(
            name: user.name,
            imageUrl: user.imageUrl,
            teachingSkill: user.teaching.name,
            isTopMatch: isTopMatch,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    userName: user.name,
                    userImageUrl: user.imageUrl,
                    userTitle: user.teaching.name,
                    isOnline: true,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockConversations.length,
      itemBuilder: (context, index) {
        final conv = mockConversations[index];
        return ConversationItem(
          userName: conv.user.name,
          userImageUrl: conv.user.imageUrl,
          lastMessage: conv.lastMessage,
          timestamp: conv.timestamp,
          skillTag: conv.skillTag,
          isOnline: conv.isOnline,
          hasUnread: conv.hasUnread,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  userName: conv.user.name,
                  userImageUrl: conv.user.imageUrl,
                  userTitle: conv.user.teaching.name,
                  isOnline: conv.isOnline,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

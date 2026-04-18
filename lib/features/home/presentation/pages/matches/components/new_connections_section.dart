import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat/chat_page.dart';
import 'new_match_bubble.dart';
import 'package:skillswap/core/theme/theme.dart';

class NewConnectionsSection extends StatelessWidget {
  final List<dynamic> matches;
  final String currentUserId;
  final Map<String, bool> onlineStatuses;

  const NewConnectionsSection({
    super.key,
    required this.matches,
    required this.currentUserId,
    required this.onlineStatuses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Connections'),
        const SizedBox(height: 24),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final conv = matches[index];
              final user = conv.user;
              return NewMatchBubble(
                key: ValueKey('bubble_${user.id}'),
                name: user.name,
                imageUrl: user.imageUrl,
                teachingSkill: user.teaching?.name ?? 'Expert',
                isTopMatch: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        userName: user.name,
                        userImageUrl: user.imageUrl,
                        userTitle: user.teaching?.name ?? 'Expert',
                        matchId: conv.matchId ?? '',
                        userId: user.id,
                        currentUserId: currentUserId,
                        status: conv.status,
                        payerId: conv.payerId,
                        isOnline: onlineStatuses[user.id] ?? false,
                      ),
                    ),
                  );
                  if (context.mounted) {
                    context.read<MatchesCubit>().fetchMatches();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    const accentColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(color: accentColor),
          ),
        ],
      ),
    );
  }
}

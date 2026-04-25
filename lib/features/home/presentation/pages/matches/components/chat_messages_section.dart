import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat/chat_page.dart';
import 'conversation_item.dart';

class ChatMessagesSection extends StatelessWidget {
  final List<dynamic> matches;
  final String currentUserId;
  final Map<String, bool> onlineStatuses;

  const ChatMessagesSection({
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
        const SizedBox(height: 24),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final conv = matches[index];
            final user = conv.user;
            return ConversationItem(
              key: ValueKey('conv_${user.id}'),
              userName: user.name,
              userImageUrl: user.imageUrl,
              lastMessage: conv.lastMessage ?? "Start your skill exchange...",
              timestamp: _formatTimestamp(conv.lastMessageTime),
              skillTag: user.teaching?.name ?? 'Expert',
              isOnline: onlineStatuses[user.id] ?? false,
              hasUnread: conv.hasUnread,
              isPaidPending: conv.status == 'pending',
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
      ],
    );
  }

  String _formatTimestamp(String? timestampStr) {
    if (timestampStr == null) return "Just now";
    try {
      final dateTime = DateTime.parse(timestampStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return "Just now";
      if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
      if (difference.inHours < 24) return "${difference.inHours}h ago";
      if (difference.inDays < 7) return "${difference.inDays}d ago";

      return "${dateTime.day}/${dateTime.month}";
    } catch (e) {
      return "Just now";
    }
  }
}

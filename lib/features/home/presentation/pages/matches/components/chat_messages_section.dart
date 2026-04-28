import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/navigation/app_router.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
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
    final slivers = buildSlivers(context);
    return CustomScrollView(slivers: slivers);
  }

  List<Widget> buildSlivers(BuildContext context) {
    final hPad = Responsive.contentHorizontalPadding(context);
    final top = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 20,
      tablet: 22,
      tabletWide: 24,
      desktop: 24,
    );

    final itemCount = matches.length;
    final gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.85,
    );

    return [
      SliverToBoxAdapter(child: SizedBox(height: top)),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        sliver: Responsive.isTwoPane(context)
            ? SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) => _buildItem(ctx, index),
                  childCount: itemCount,
                ),
                gridDelegate: gridDelegate,
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) => _buildItem(ctx, index),
                  childCount: itemCount,
                ),
              ),
      ),
    ];
  }

  Widget _buildItem(BuildContext context, int index) {
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
        AppRouter.toChat(
          context,
          userName: user.name,
          userImageUrl: user.imageUrl,
          userTitle: user.teaching?.name ?? 'Expert',
          matchId: conv.matchId ?? '',
          userId: user.id,
          currentUserId: currentUserId,
          status: conv.status,
          payerId: conv.payerId,
          isOnline: onlineStatuses[user.id] ?? false,
        );
        if (context.mounted) {
          context.read<MatchesCubit>().fetchMatches();
        }
      },
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

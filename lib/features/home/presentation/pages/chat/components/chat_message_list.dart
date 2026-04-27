import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'message_bubble.dart';
import 'package:skillswap/core/theme/theme.dart';

class ChatMessageList extends StatelessWidget {
  final ChatState state;
  final ScrollController scrollController;
  final String currentUserId;
  final String matchId;
  final String userId;
  final Future<void> Function() onRefresh;

  const ChatMessageList({
    super.key,
    required this.state,
    required this.scrollController,
    required this.currentUserId,
    required this.matchId,
    required this.userId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ChatLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ChatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.24),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Chat Offline",
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.30),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (state as ChatError).message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary.withValues(alpha: 0.24),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatMessagesLoaded) {
      final messagesLoaded = state as ChatMessagesLoaded;
      if (messagesLoaded.messages.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.overlay03,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start the Flow',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No messages yet. Send a message to start the conversation!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: AppColors.overlay30,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final topPad = MediaQuery.paddingOf(context).top +
          Responsive.valueFor<double>(
            context,
            compact: 72,
            mobile: 80,
            tablet: 88,
            tabletWide: 96,
            desktop: 100,
          );
      final hPad = Responsive.contentHorizontalPadding(context);

      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, 20),
          itemCount: messagesLoaded.messages.length,
          itemBuilder: (context, index) {
            final msg = messagesLoaded.messages[index];
            final isMe = msg.senderId == currentUserId;

            return MessageBubble(
              text: msg.content,
              isMe: isMe,
              time: DateFormat('h:mm a').format(msg.timestamp),
              isRead: msg.isRead,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

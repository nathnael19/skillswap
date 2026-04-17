import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'message_bubble.dart';

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
        child: CircularProgressIndicator(color: Color(0xFFCA8A04)),
      );
    }

    if (state is ChatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white24,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Chat Offline",
                style: GoogleFonts.dmSans(
                  color: Colors.white30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (state as ChatError).message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: Colors.white24, fontSize: 13),
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
                    color: Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFCA8A04),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start the Flow',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No messages yet. Send a message to start the conversation!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.3),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFFCA8A04),
        backgroundColor: const Color(0xFF1C1917),
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
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

import 'package:flutter/material.dart';
import 'package:skillswap/features/home/presentation/pages/chat/chat_page.dart';
import 'package:skillswap/features/live_sessions/presentation/pages/session_detail_page.dart';

class AppRouter {
  const AppRouter._();

  static Future<void> toChat(
    BuildContext context, {
    required String userName,
    required String userImageUrl,
    required String userTitle,
    required String matchId,
    required String userId,
    required String currentUserId,
    required String status,
    required String? payerId,
    required bool isOnline,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          userName: userName,
          userImageUrl: userImageUrl,
          userTitle: userTitle,
          matchId: matchId,
          userId: userId,
          currentUserId: currentUserId,
          status: status,
          payerId: payerId,
          isOnline: isOnline,
        ),
      ),
    );
  }

  static Future<void> toSessionDetail(BuildContext context, String sessionId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(sessionId: sessionId),
      ),
    );
  }
}

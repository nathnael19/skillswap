import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/features/live_sessions/data/models/live_session_model.dart';
import 'package:skillswap/features/live_sessions/data/services/live_session_firestore_service.dart';
import 'package:skillswap/features/live_sessions/presentation/pages/session_detail_page.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/init_dependencies.dart';

class ChatQuickActions extends StatefulWidget {
  final String matchId;
  final String peerName;
  final String peerImageUrl;
  final String currentUserId;
  final String peerId;
  final String? currentUserName;
  final String? currentUserImageUrl;

  const ChatQuickActions({
    super.key,
    required this.matchId,
    required this.peerName,
    required this.peerImageUrl,
    required this.currentUserId,
    required this.peerId,
    this.currentUserName,
    this.currentUserImageUrl,
  });

  @override
  State<ChatQuickActions> createState() => _ChatQuickActionsState();
}

class _ChatQuickActionsState extends State<ChatQuickActions> {
  void _navigateToSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleSessionPage(
          matchId: widget.matchId,
          peerName: widget.peerName,
          peerImageUrl: widget.peerImageUrl,
          currentUserId: widget.currentUserId,
          peerId: widget.peerId,
          currentUserName: widget.currentUserName,
          currentUserImageUrl: widget.currentUserImageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: StreamBuilder<List<LiveSession>>(
        stream: serviceLocator<LiveSessionFirestoreService>()
            .watchOneOnOneSessions(widget.currentUserId, widget.peerId),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? [];
          final activeSession = sessions.isNotEmpty ? sessions.first : null;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LOGISTICS',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                if (activeSession == null)
                  _buildActionButton(
                    context,
                    'Schedule 1-to-1 Session',
                    Icons.calendar_today_rounded,
                    () => _navigateToSchedule(context),
                  )
                else ...[
                  _buildSessionCard(context, activeSession),
                  const SizedBox(width: 12),
                  _buildAddButton(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, LiveSession session) {
    final dateStr = DateFormat('MMM d, h:mm a').format(session.scheduledAt);
    final isLive = session.status == 'live';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailPage(sessionId: session.sessionId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isLive 
              ? AppColors.error.withValues(alpha: 0.1) 
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive 
                ? AppColors.error.withValues(alpha: 0.3) 
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isLive ? Icons.sensors_rounded : Icons.event_available_rounded,
              size: 14,
              color: isLive ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isLive ? 'Session is LIVE' : 'Scheduled: $dateStr',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isLive ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSchedule(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay08),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback? onTap,
  ) {
    const accentColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay08),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

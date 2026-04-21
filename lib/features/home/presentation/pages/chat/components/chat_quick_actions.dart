import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/core/theme/theme.dart';

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
  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SingleChildScrollView(
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
                  'Quick Actions',
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
            _buildActionButton(context, 'Schedule 1-to-1 Session', () {
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
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
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

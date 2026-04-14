import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/pages/live_session_page.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

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
  bool _isCreatingSession = false;

  Future<void> _createInstantSession() async {
    setState(() => _isCreatingSession = true);
    final repo = serviceLocator<HomeRepository>();
    
    // We pass peerId as payerId because the Caller (Expert) initiates the call, but the other person (Learner) pays.
    final result = await repo.createSession(
      matchId: widget.matchId,
      scheduledTime: DateTime.now(),
      payerId: widget.peerId, 
    );
    
    if (!mounted) return;
    setState(() => _isCreatingSession = false);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (data) {
        final id = data['id'] as String?;
        if (id == null) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveSessionPage(
              agenda: const ['Instant Synergy Check'],
              sessionId: id,
              peerName: widget.peerName,
              peerImageUrl: widget.peerImageUrl,
              currentUserId: widget.currentUserId,
              peerId: widget.peerId,
              currentUserName: widget.currentUserName,
              currentUserImageUrl: widget.currentUserImageUrl,
              isCaller: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

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
                  'QUICK ACTIONS',
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
            _buildActionButton(
              context, 
              _isCreatingSession ? 'Starting...' : 'Call now', 
              _isCreatingSession ? null : _createInstantSession,
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              context, 
              'Schedule a 30m swap', 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleSessionPage(
                      matchId: widget.matchId,
                      peerName: widget.peerName,
                      peerImageUrl: widget.peerImageUrl,
                      currentUserId: widget.currentUserId,
                      peerId: widget.peerId,
                    ),
                  ),
                );
              },
            ),
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
    const accentColor = Color(0xFFCA8A04);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/presence_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/master_profile/master_profile_page.dart';
import 'package:skillswap/features/home/presentation/pages/schedule_session_page.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userImageUrl;
  final String userTitle;
  final String matchId;
  final String userId;
  final String currentUserId;
  final User? currentUser;

  const ChatAppBar({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.userTitle,
    required this.matchId,
    required this.userId,
    required this.currentUserId,
    this.currentUser,
  });

  static const Color primaryBgColor = Color(0xFF0C0A09);
  static const Color accentColor = Color(0xFFCA8A04);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppBar(
          backgroundColor: primaryBgColor.withValues(alpha: 0.8),
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<PresenceCubit, PresenceState>(
            builder: (context, presenceState) {
              final isOnline = presenceState.isOnline;
              final isTyping = presenceState.isTyping;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MasterProfilePage(userId: userId),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isOnline
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: userImageUrl.startsWith('assets')
                                ? AssetImage(userImageUrl)
                                : NetworkImage(userImageUrl) as ImageProvider,
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryBgColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.dmSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTyping
                                ? 'typing...'
                                : '$userTitle • ${isOnline ? 'Active now' : 'Offline'}',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isTyping || isOnline
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.3),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleSessionPage(
                        matchId: matchId,
                        peerName: userName,
                        peerImageUrl: userImageUrl,
                        currentUserId: currentUserId,
                        peerId: userId,
                        currentUserName: currentUser?.name,
                        currentUserImageUrl: currentUser?.imageUrl,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

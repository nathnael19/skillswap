import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/chat_state.dart';
import 'package:skillswap/features/home/presentation/pages/live_session/live_session_page.dart';
import 'package:skillswap/core/theme/theme.dart';

class IncomingCallOverlay extends StatelessWidget {
  final ChatIncomingCall state;
  final String? currentUserName;
  final String? currentUserImageUrl;
  final String matchId;
  final String userId;
  final String currentUserId;
  final String userName;
  final String userImageUrl;

  const IncomingCallOverlay({
    super.key,
    required this.state,
    required this.currentUserName,
    required this.currentUserImageUrl,
    required this.matchId,
    required this.userId,
    required this.currentUserId,
    required this.userName,
    required this.userImageUrl,
  });

  static const Color accentColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.overlay10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundImage:
                              state.peerImageUrl.startsWith('assets')
                              ? AssetImage(state.peerImageUrl)
                              : NetworkImage(state.peerImageUrl)
                                    as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Session Request',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.peerName,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ChatCubit>().rejectCall(
                              targetId: state.peerId,
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.overlay05,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Decline',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary.withValues(alpha: 0.54),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LiveSessionPage(
                                  agenda: const ['Spontaneous Synergy'],
                                  peerName: userName,
                                  peerImageUrl: userImageUrl,
                                  currentUserId: currentUserId,
                                  peerId: userId,
                                  currentUserName: currentUserName,
                                  currentUserImageUrl: currentUserImageUrl,
                                  isCaller: false,
                                ),
                              ),
                            );
                            context.read<ChatCubit>().loadMessages(
                              matchId,
                              userId,
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [accentColor, AppColors.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

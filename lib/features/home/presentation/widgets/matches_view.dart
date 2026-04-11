import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/conversation_item.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/new_match_bubble.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          return BlocBuilder<MatchesCubit, MatchesState>(
            builder: (context, state) {
              if (state is MatchesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MatchesError) {
                return _buildErrorView(context, state.message);
              }

              if (state is MatchesLoaded) {
                final matches = state.matches;

                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No matches yet!",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Start swiping to find skill-swap partners.",
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<MatchesCubit>().fetchMatches(),
                  color: const Color(0xFF0B6A7A),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionHeader('NEW MATCHES • SUCCESS'),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: matches.map((conv) {
                                final user = conv.user;
                                return NewMatchBubble(
                                  name: user.name,
                                  imageUrl: user.imageUrl,
                                  teachingSkill:
                                      user.teaching?.name ?? 'Expert',
                                  isTopMatch: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          userName: user.name,
                                          userImageUrl: user.imageUrl,
                                          userTitle:
                                              user.teaching?.name ?? 'Expert',
                                          matchId: user.matchId ?? '',
                                          userId: user.id,
                                          isOnline: true,
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      // Refresh matches when returning from chat
                                      context.read<MatchesCubit>().fetchMatches();
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('CONVERSATIONS • ACTIVE'),
                          const SizedBox(height: 16),
                          // Use ListView.builder with shrinkWrap inside SingleChildScrollView
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final conv = matches[index];
                              final user = conv.user;
                              return ConversationItem(
                                userName: user.name,
                                userImageUrl: user.imageUrl,
                                lastMessage:
                                    conv.lastMessage ?? "Start a conversation!",
                                timestamp: _formatTimestamp(
                                  conv.lastMessageTime,
                                ),
                                skillTag: user.teaching?.name ?? 'Expert',
                                isOnline: true,
                                hasUnread: conv.hasUnread,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        userName: user.name,
                                        userImageUrl: user.imageUrl,
                                        userTitle:
                                            user.teaching?.name ?? 'Expert',
                                        matchId: user.matchId ?? '',
                                        userId: user.id,
                                        isOnline: true,
                                      ),
                                    ),
                                  );
                                  if (context.mounted) {
                                    // Refresh matches when returning from chat to clear unread dots
                                    context.read<MatchesCubit>().fetchMatches();
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        }

        // Guest Mode or Loading Auth
        return _buildGuestWall(context);
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Sync Interrupted",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't reach the matches database. Please check your connection.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.read<MatchesCubit>().fetchMatches(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("RETRY CONNECTION"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B6A7A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestWall(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handshake_rounded,
              color: Color(0xFF0B6A7A),
              size: 64,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Your Connections',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Once you connect with an expert, your shared journey and messages will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF667085),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(OnboardingPage.route());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6A7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            child: Text(
              'LOG IN TO YOUR ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0B6A7A),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0B6A7A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

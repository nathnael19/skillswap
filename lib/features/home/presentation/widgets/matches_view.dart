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
    const primaryBgColor = Color(0xFF0C0A09);
    const accentColor = Color(0xFFCA8A04);
    
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          backgroundColor: primaryBgColor,
          body: authState is AuthSuccess
              ? BlocBuilder<MatchesCubit, MatchesState>(
                  builder: (context, state) {
                    if (state is MatchesLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: accentColor,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (state is MatchesError) {
                      return _buildErrorView(context, state.message);
                    }

                    if (state is MatchesLoaded) {
                      final matches = state.matches;

                      if (matches.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<MatchesCubit>().fetchMatches(),
                        color: accentColor,
                        backgroundColor: const Color(0xFF1C1917),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            const SizedBox(height: 32),
                            _buildSectionHeader('NEW CONNECTIONS'),
                            const SizedBox(height: 24),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Row(
                                children: matches.map((conv) {
                                  final user = conv.user;
                                  return NewMatchBubble(
                                    name: user.name,
                                    imageUrl: user.imageUrl,
                                    teachingSkill:
                                        user.teaching?.name ?? 'Expert',
                                    isTopMatch: true, // Making them glow for premium feel
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
                                        context
                                            .read<MatchesCubit>()
                                            .fetchMatches();
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 54),
                            _buildSectionHeader('CENTRAL MESSAGES'),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: matches.map((conv) {
                                  final user = conv.user;
                                  return ConversationItem(
                                    userName: user.name,
                                    userImageUrl: user.imageUrl,
                                    lastMessage:
                                        conv.lastMessage ??
                                        "Start your skill exchange...",
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
                                        context
                                            .read<MatchesCubit>()
                                            .fetchMatches();
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 120), // Extra space for nav bar
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                )
              : _buildGuestWall(context),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: accentColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              "The Void Awaits",
              style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Start discovering masterminds to manifest\nyour collaborative success.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.3),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    const accentColor = Color(0xFFCA8A04);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 24),
            Text(
              "HUB OFFLINE",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We encountered an echo in the matrix. Reconnect to manifest your matches.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Colors.white.withValues(alpha: 0.4),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => context.read<MatchesCubit>().fetchMatches(),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "RETRY CONNECTION",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestWall(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: accentColor,
              size: 80,
            ),
          ),
          const SizedBox(height: 54),
          Text(
            'Manifest Growth',
            style: GoogleFonts.dmSans(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Unlock your matched connections and shared knowledge journeys by becoming a member.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              color: Colors.white.withValues(alpha: 0.3),
              height: 1.7,
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentColor, Color(0xFFB47B03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(OnboardingPage.route());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  'Start Manifesting',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            child: Text(
              'LOG IN TO YOUR HUB',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 48),
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
    const accentColor = Color(0xFFCA8A04);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

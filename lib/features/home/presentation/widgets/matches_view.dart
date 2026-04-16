import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat_page.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/presentation/pages/search_page.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/conversation_item.dart';
import 'package:skillswap/features/home/presentation/widgets/matches/new_match_bubble.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const GuestWall();
        }

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: _buildHeader(context),
              ),
              Expanded(
                child: BlocBuilder<MatchesCubit, MatchesState>(
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
                      return AppErrorWidget(
                        message: state.message,
                        onRetry: () =>
                            context.read<MatchesCubit>().fetchMatches(),
                      );
                    }

                    if (state is MatchesLoaded) {
                      final matches = state.matches;
                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<MatchesCubit>().fetchMatches(),
                        color: accentColor,
                        backgroundColor: const Color(0xFF1C1917),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12),
                            ),
                            SliverToBoxAdapter(
                              child: _buildSectionHeader('New Connections'),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  itemCount: matches.length,
                                  itemBuilder: (context, index) {
                                    final conv = matches[index];
                                    final user = conv.user;
                                    return NewMatchBubble(
                                      key: ValueKey('bubble_${user.id}'),
                                      name: user.name,
                                      imageUrl: user.imageUrl,
                                      teachingSkill:
                                          user.teaching?.name ?? 'Expert',
                                      isTopMatch: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              userName: user.name,
                                              userImageUrl: user.imageUrl,
                                              userTitle:
                                                  user.teaching?.name ??
                                                  'Expert',
                                              matchId: conv.matchId ?? '',
                                              userId: user.id,
                                              currentUserId: authState.uid,
                                              status: conv.status,
                                              payerId: conv.payerId,
                                              isOnline:
                                                  state.onlineStatuses[user
                                                      .id] ??
                                                  false,
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
                                  },
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 54),
                            ),
                            SliverToBoxAdapter(
                              child: _buildSectionHeader('Chat Messages'),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              sliver: SliverList.builder(
                                itemCount: matches.length,
                                itemBuilder: (context, index) {
                                  final conv = matches[index];
                                  final user = conv.user;
                                  return ConversationItem(
                                    key: ValueKey('conv_${user.id}'),
                                    userName: user.name,
                                    userImageUrl: user.imageUrl,
                                    lastMessage:
                                        conv.lastMessage ??
                                        "Start your skill exchange...",
                                    timestamp: _formatTimestamp(
                                      conv.lastMessageTime,
                                    ),
                                    skillTag: user.teaching?.name ?? 'Expert',
                                    isOnline:
                                        state.onlineStatuses[user.id] ?? false,
                                    hasUnread: conv.hasUnread,
                                    isPaidPending: conv.status == 'pending',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            userName: user.name,
                                            userImageUrl: user.imageUrl,
                                            userTitle:
                                                user.teaching?.name ?? 'Expert',
                                            matchId: conv.matchId ?? '',
                                            userId: user.id,
                                            currentUserId: authState.uid,
                                            status: conv.status,
                                            payerId: conv.payerId,
                                            isOnline:
                                                state.onlineStatuses[user.id] ??
                                                false,
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
                                },
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 120),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 56,
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "No connections yet",
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Explore experts and start chatting to share skills.",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.3),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                  'CONNECTIONS',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildHeaderAction(
                  icon: Icons.search_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildHeaderAction(
                  icon: Icons.tune_rounded,
                  onTap: () {
                    // This is usually handled in HomePage, but we can potentially
                    // trigger it here if we pass a callback or use a global key.
                    // For now, we'll leave it as a placeholder or use a simple logic.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter from home tab')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Find Synergy',
          style: GoogleFonts.dmSans(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
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

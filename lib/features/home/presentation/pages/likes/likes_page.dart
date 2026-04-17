import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import '../../../domain/models/user_model.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'components/like_card.dart';
import 'components/likes_empty_state.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const GuestWall();
        }

        return DefaultTabController(
          length: 3,
          child: BlocBuilder<LikesCubit, LikesState>(
            builder: (context, state) {
              if (state is LikesLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: accentColor,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is LikesError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<LikesCubit>().fetchLikes(),
                );
              }

              if (state is LikesLoaded) {
                return SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: _buildHeader(),
                      ),
                      // Premium Glassy TabBar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: accentColor,
                          unselectedLabelColor: Colors.white.withValues(
                            alpha: 0.3,
                          ),
                          labelStyle: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                          labelPadding: EdgeInsets.zero,
                          tabs: const [
                            Tab(text: 'Interests'),
                            Tab(text: 'Likes'),
                            Tab(text: 'History'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildLikesList(
                              context,
                              state.receivedLikes,
                              'No interests yet',
                              'When people show interest in your skills, they\'ll appear here.',
                              isReceived: true,
                            ),
                            _buildLikesList(
                              context,
                              state.sentLikes,
                              'No likes sent yet',
                              'Start exploring and liking expert profiles to connect.',
                              isSent: true,
                            ),
                            _buildLikesList(
                              context,
                              state.passedUsers,
                              'No history',
                              'Your passed profiles and past activity will show up here.',
                              isPassed: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    const accentColor = Color(0xFFCA8A04);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Your Feed',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Discover Experts',
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

  Widget _buildLikesList(
    BuildContext context,
    List<User> users,
    String emptyTitle,
    String emptySubtitle, {
    bool isReceived = false,
    bool isSent = false,
    bool isPassed = false,
  }) {
    const accentColor = Color(0xFFCA8A04);

    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<LikesCubit>().fetchLikes();
          if (context.mounted) {
            await context.read<MatchesCubit>().fetchMatches();
          }
        },
        color: accentColor,
        backgroundColor: const Color(0xFF1C1917),
        child: LikesEmptyState(
          title: emptyTitle,
          subtitle: emptySubtitle,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<LikesCubit>().fetchLikes();
        if (context.mounted) {
          await context.read<MatchesCubit>().fetchMatches();
        }
      },
      color: accentColor,
      backgroundColor: const Color(0xFF1C1917),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return LikeCard(
            user: users[index],
            isReceived: isReceived,
            isSent: isSent,
            isPassed: isPassed,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import '../../../domain/models/user_model.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'components/like_card.dart';
import 'components/likes_empty_state.dart';
import 'package:skillswap/core/theme/theme.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const GuestWall();
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityStatus>(
              listenWhen: (prev, curr) =>
                  prev == ConnectivityStatus.disconnected &&
                  curr == ConnectivityStatus.connected,
              listener: (context, _) {
                context.read<LikesCubit>().fetchLikes();
              },
            ),
          ],
          child: DefaultTabController(
            length: 3,
            child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
              builder: (context, connectivity) {
                return BlocBuilder<LikesCubit, LikesState>(
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
                      if (connectivity == ConnectivityStatus.disconnected) {
                        return OfflineScreen(
                          onRetry: () => context.read<LikesCubit>().fetchLikes(),
                        );
                      }
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
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: TabBar(
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  color: AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: AppColors.borderDefault),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: accentColor,
                                unselectedLabelColor: AppColors.textPrimary.withValues(alpha: 0.3),
                                labelStyle: AppTextStyles.labelSmall.copyWith(
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

                    if (connectivity == ConnectivityStatus.disconnected) {
                      return OfflineScreen(
                        onRetry: () => context.read<LikesCubit>().fetchLikes(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    const accentColor = AppColors.primary;

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
              style: AppTextStyles.labelSmall.copyWith(color: accentColor),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Discover Experts', style: AppTextStyles.h1),
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
    const accentColor = AppColors.primary;

    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<LikesCubit>().fetchLikes();
          if (context.mounted) {
            await context.read<MatchesCubit>().fetchMatches();
          }
        },
        color: accentColor,
        backgroundColor: AppColors.surface,
        child: LikesEmptyState(title: emptyTitle, subtitle: emptySubtitle),
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
      backgroundColor: AppColors.surface,
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

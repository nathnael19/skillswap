import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'components/matches_header.dart';
import 'components/matches_empty_state.dart';
import 'components/new_connections_section.dart';
import 'components/chat_messages_section.dart';
import 'package:skillswap/core/theme/theme.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;

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
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: MatchesHeader(),
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
                      if (matches.isEmpty) {
                        return const MatchesEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<MatchesCubit>().fetchMatches(),
                        color: accentColor,
                        backgroundColor: AppColors.surface,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12),
                            ),
                            SliverToBoxAdapter(
                              child: NewConnectionsSection(
                                matches: matches,
                                currentUserId: authState.uid,
                                onlineStatuses: state.onlineStatuses,
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 30),
                            ),
                            SliverToBoxAdapter(
                              child: ChatMessagesSection(
                                matches: matches,
                                currentUserId: authState.uid,
                                onlineStatuses: state.onlineStatuses,
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
}

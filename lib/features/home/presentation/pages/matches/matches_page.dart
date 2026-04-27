import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/home/presentation/cubits/matches_cubit.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/core/common/widgets/guest_wall.dart';
import 'components/matches_header.dart';
import 'components/matches_empty_state.dart';
import 'components/chat_messages_section.dart';
import 'package:skillswap/core/layout/responsive.dart';
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

        return MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityStatus>(
              listenWhen: (prev, curr) =>
                  prev == ConnectivityStatus.disconnected &&
                  curr == ConnectivityStatus.connected,
              listener: (context, _) {
                context.read<MatchesCubit>().fetchMatches();
              },
            ),
          ],
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.contentHorizontalPadding(context),
                    0,
                    Responsive.contentHorizontalPadding(context),
                    12,
                  ),
                  child: MatchesHeader(),
                ),
                Expanded(
                  child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
                    builder: (context, connectivity) {
                      return BlocBuilder<MatchesCubit, MatchesState>(
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
                            if (connectivity ==
                                ConnectivityStatus.disconnected) {
                              return OfflineScreen(
                                onRetry: () =>
                                    context.read<MatchesCubit>().fetchMatches(),
                              );
                            }
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: ChatMessagesSection(
                                      matches: matches,
                                      currentUserId: authState.uid,
                                      onlineStatuses: state.onlineStatuses,
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Responsive.valueFor<double>(
                                        context,
                                        compact: 96,
                                        mobile: 108,
                                        tablet: 112,
                                        tabletWide: 120,
                                        desktop: 120,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (connectivity == ConnectivityStatus.disconnected) {
                            return OfflineScreen(
                              onRetry: () =>
                                  context.read<MatchesCubit>().fetchMatches(),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

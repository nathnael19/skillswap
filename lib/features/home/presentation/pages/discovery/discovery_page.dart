import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/features/home/presentation/cubits/credits_cubit.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/pages/chat/chat_page.dart';
import 'components/empty_discovery_state.dart';
import 'components/swipeable_card_stack.dart';
import '../../shared/premium_dialogs.dart';
import 'package:skillswap/init_dependencies.dart';
import 'package:skillswap/core/constants/app_constants.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/core/common/cubits/connectivity/connectivity_cubit.dart';
import 'package:skillswap/core/common/widgets/offline_screen.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  int _currentIndex = 0;

  void _nextCard(bool isLiked) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      // Allow visual swiping for guests to explore
      setState(() {
        _currentIndex++;
      });
      return;
    }

    final state = context.read<DiscoveryCubit>().state;
    if (state is DiscoveryLoaded) {
      final users = state.users;
      if (_currentIndex < users.length) {
        final targetId = users[_currentIndex].id;
        context.read<DiscoveryCubit>().swipeUser(
          targetId: targetId,
          direction: isLiked ? 'like' : 'dislike',
        );

        setState(() {
          _currentIndex++;
        });
      }
    }
  }

  void _navigateToChat(
    BuildContext context,
    String currentUserId,
    String matchId,
    dynamic user, {
    String status = 'mutual',
    String? payerId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userName: user.name,
          userImageUrl: user.imageUrl,
          userTitle: user.profession,
          matchId: matchId,
          userId: user.id,
          currentUserId: currentUserId,
          status: status,
          payerId: payerId,
        ),
      ),
    );
  }

  void _showPaidMessageDialog(
    BuildContext context,
    String currentUserId,
    dynamic user,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => PremiumActionDialog(
        title: "Instant Connection",
        description:
            "Connect with ${user.name} immediately for ${AppConstants.paidChatCostLabel}. This will open a permanent chat channel.",
        actionLabel: "Message Now",
        costLabel: AppConstants.paidChatCostLabel,
        onConfirm: () async {
          final result = await serviceLocator<HomeRepository>().initPaidChat(
            user.id,
          );

          if (!context.mounted) return;

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            (matchId) {
              // Refresh credits after spending
              context.read<CreditsCubit>().fetchCredits();

              _navigateToChat(
                context,
                currentUserId,
                matchId,
                user,
                status: 'pending',
                payerId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }

  void _handleChat(dynamic user) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      if (user.matchId != null) {
        _navigateToChat(
          context,
          authState.uid,
          user.matchId!,
          user,
          status: user.matchStatus ?? 'mutual',
          payerId: user.matchPayerId,
        );
      } else {
        _showPaidMessageDialog(context, authState.uid, user);
      }
    } else {
      Navigator.of(context).push(OnboardingPage.route());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectivityCubit, ConnectivityStatus>(
          listenWhen: (prev, curr) =>
              prev == ConnectivityStatus.disconnected &&
              curr == ConnectivityStatus.connected,
          listener: (context, _) {
            context.read<DiscoveryCubit>().fetchDiscoveryUsers();
          },
        ),
        BlocListener<DiscoveryCubit, DiscoveryState>(
          listener: (context, state) {
            if (state is DiscoverySwipeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is DiscoveryLoaded) {
              setState(() {
                _currentIndex = 0;
              });
            }
          },
        ),
      ],
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, connectivity) {
          return BlocBuilder<DiscoveryCubit, DiscoveryState>(
            builder: (context, state) {
              if (state is DiscoveryLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is DiscoveryError) {
                if (connectivity == ConnectivityStatus.disconnected) {
                  return OfflineScreen(
                    onRetry: () => context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                  );
                }
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                );
              }

              if (state is DiscoveryLoaded) {
                final users = state.users;
                final hasMoreUsers = _currentIndex < users.length;

                if (!hasMoreUsers) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: const EmptyDiscoveryState(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: SwipeableCardStack(
                    users: users,
                    currentIndex: _currentIndex,
                    onSwiped: _nextCard,
                    onChat: _handleChat,
                  ),
                );
              }

              if (connectivity == ConnectivityStatus.disconnected) {
                return OfflineScreen(
                  onRetry: () => context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

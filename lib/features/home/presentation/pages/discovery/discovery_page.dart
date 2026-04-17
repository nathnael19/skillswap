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
            "Connect with ${user.name} immediately for 1 Coin. This will open a permanent chat channel.",
        actionLabel: "Message Now",
        costLabel: "1 Coin",
        onConfirm: () async {
          final result =
              await serviceLocator<HomeRepository>().initPaidChat(user.id);

          if (!context.mounted) return;

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Colors.redAccent,
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
        _showPaidMessageDialog(
          context,
          authState.uid,
          user,
        );
      }
    } else {
      Navigator.of(context).push(
        OnboardingPage.route(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoveryCubit, DiscoveryState>(
      listener: (context, state) {
        if (state is DiscoveryLoaded) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCA8A04),
                strokeWidth: 2,
              ),
            );
          }

          if (state is DiscoveryError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
            );
          }

          if (state is DiscoveryLoaded) {
            final users = state.users;
            final hasMoreUsers = _currentIndex < users.length;

            if (!hasMoreUsers) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                color: const Color(0xFFCA8A04),
                backgroundColor: const Color(0xFF1C1917),
                child: const EmptyDiscoveryState(),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
              color: const Color(0xFFCA8A04),
              backgroundColor: const Color(0xFF1C1917),
              child: SwipeableCardStack(
                users: users,
                currentIndex: _currentIndex,
                onSwiped: _nextCard,
                onChat: _handleChat,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

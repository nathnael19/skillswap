import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/discovery/swipe_action_buttons.dart';
import 'package:skillswap/features/home/presentation/widgets/discovery/swipeable_card.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
import 'package:skillswap/core/common/widgets/app_error_widget.dart';
import 'package:skillswap/features/auth/presentation/pages/onboarding_page.dart';

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _likeOpacityAnimation;
  bool _showHeart = false;

  late AnimationController _dislikeAnimationController;
  late Animation<double> _dislikeScaleAnimation;
  late Animation<double> _dislikeOpacityAnimation;
  late Animation<double> _dislikeShakeAnimation;
  bool _showClose = false;

  // Swipe State
  Offset _swipeOffset = Offset.zero;
  double _swipeAngle = 0;
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipePositionAnimation;
  late Animation<double> _swipeAngleAnimation;
  bool _isAnimatingOffScreen = false;

  @override
  void initState() {
    super.initState();
    _initLikeAnimations();
    _initDislikeAnimations();
    _initSwipeAnimations();
  }

  void _initLikeAnimations() {
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_likeAnimationController);

    _likeOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_likeAnimationController);
  }

  void _initDislikeAnimations() {
    _dislikeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dislikeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_dislikeAnimationController);

    _dislikeOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_dislikeAnimationController);

    _dislikeShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1),
        weight: 50,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 0.0), weight: 25),
    ]).animate(_dislikeAnimationController);
  }

  void _initSwipeAnimations() {
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _swipeAnimationController.addListener(() {
      setState(() {
        _swipeOffset = _swipePositionAnimation.value;
        _swipeAngle = _swipeAngleAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _dislikeAnimationController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    setState(() {
      _showHeart = true;
      _showClose = false;
    });
    _likeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showHeart = false;
      });
      _nextCard(true);
    });
  }

  void _triggerDislikeAnimation() {
    setState(() {
      _showClose = true;
      _showHeart = false;
    });
    _dislikeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showClose = false;
      });
      _nextCard(false);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimatingOffScreen) return;
    setState(() {
      _swipeOffset += details.delta;
      _swipeAngle = _swipeOffset.dx / 1000;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimatingOffScreen) return;
    final threshold = MediaQuery.of(context).size.width / 4;
    if (_swipeOffset.dx > threshold) {
      _runSwipeAnimation(true);
    } else if (_swipeOffset.dx < -threshold) {
      _runSwipeAnimation(false);
    } else {
      _runSwipeAnimation(null);
    }
  }

  void _runSwipeAnimation(bool? isLiked) {
    if (_isAnimatingOffScreen) return;
    setState(() => _isAnimatingOffScreen = true);

    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = isLiked == null
        ? Offset.zero
        : Offset(isLiked ? screenWidth * 1.5 : -screenWidth * 1.5, 0);

    double targetAngle = 0;
    if (isLiked != null) {
      if (_swipeAngle.abs() < 0.01) {
        targetAngle = isLiked ? 0.4 : -0.4;
      } else {
        targetAngle = _swipeAngle * 2;
      }
    }

    _swipePositionAnimation =
        Tween<Offset>(begin: _swipeOffset, end: targetOffset).animate(
          CurvedAnimation(
            parent: _swipeAnimationController,
            curve: Curves.easeOut,
          ),
        );

    _swipeAngleAnimation = Tween<double>(begin: _swipeAngle, end: targetAngle)
        .animate(
          CurvedAnimation(
            parent: _swipeAnimationController,
            curve: Curves.easeOut,
          ),
        );

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _swipeAnimationController.removeStatusListener(statusListener);
        if (isLiked != null) {
          if (isLiked) {
            _triggerLikeAnimation();
          } else {
            _triggerDislikeAnimation();
          }
        } else {
          setState(() => _isAnimatingOffScreen = false);
        }
      }
    }

    _swipeAnimationController.addStatusListener(statusListener);
    _swipeAnimationController.forward(from: 0.0);
  }

  void _nextCard(bool isLiked) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      Navigator.of(context).push(OnboardingPage.route());
      setState(() {
        _swipeOffset = Offset.zero;
        _swipeAngle = 0;
        _isAnimatingOffScreen = false;
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
          _swipeOffset = Offset.zero;
          _swipeAngle = 0;
          _isAnimatingOffScreen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiscoveryCubit, DiscoveryState>(
      listener: (context, state) {
        if (state is DiscoveryLoaded) {
          setState(() {
            _currentIndex = 0;
            _swipeOffset = Offset.zero;
            _swipeAngle = 0;
            _isAnimatingOffScreen = false;
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
            final isInteractionDisabled =
                _isAnimatingOffScreen || _showHeart || _showClose;

            if (!hasMoreUsers) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                color: const Color(0xFFCA8A04),
                backgroundColor: const Color(0xFF1C1917),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFCA8A04,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFCA8A04),
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              "All Caught Up",
                              style: GoogleFonts.dmSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "You've explored all the talent for now. Come back soon for fresh connections.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.5),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final currentUser = users[_currentIndex];

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
              color: const Color(0xFFCA8A04),
              backgroundColor: const Color(0xFF1C1917),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // Next Card (Background)
                                  if (_currentIndex + 1 < users.length)
                                    Transform.scale(
                                      scale:
                                          0.9 +
                                          (_swipeOffset.dx.abs() / 2000).clamp(
                                            0,
                                            0.1,
                                          ),
                                      child: Opacity(
                                        opacity:
                                            0.3 +
                                            (_swipeOffset.dx.abs() / 1000)
                                                .clamp(0, 0.5),
                                        child: SwipeableCard(
                                          user: users[_currentIndex + 1],
                                        ),
                                      ),
                                    ),

                                  // Top Card (Draggable)
                                  GestureDetector(
                                    onDoubleTap: _triggerLikeAnimation,
                                    onPanUpdate: _onPanUpdate,
                                    onPanEnd: _onPanEnd,
                                    child: Transform.translate(
                                      offset: _swipeOffset,
                                      child: Transform.rotate(
                                        angle: _swipeAngle,
                                        child: SwipeableCard(user: currentUser),
                                      ),
                                    ),
                                  ),

                                  // Like overlay
                                  if (_showHeart)
                                    IgnorePointer(
                                      child: AnimatedBuilder(
                                        animation: _likeAnimationController,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity:
                                                _likeOpacityAnimation.value,
                                            child: Transform.scale(
                                              scale: _likeScaleAnimation.value,
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 5,
                                                  sigmaY: 5,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    32,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFCA8A04,
                                                    ).withValues(alpha: 0.3),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFCA8A04,
                                                      ).withValues(alpha: 0.5),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.favorite_rounded,
                                                    color: Colors.white,
                                                    size: 80,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  // Dislike overlay
                                  if (_showClose)
                                    IgnorePointer(
                                      child: AnimatedBuilder(
                                        animation: _dislikeAnimationController,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity:
                                                _dislikeOpacityAnimation.value,
                                            child: Transform.rotate(
                                              angle:
                                                  _dislikeShakeAnimation.value,
                                              child: Transform.scale(
                                                scale: _dislikeScaleAnimation
                                                    .value,
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 5,
                                                    sigmaY: 5,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          32,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.white,
                                                      size: 80,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  // Action Buttons Row
                                  Positioned(
                                    bottom: -40,
                                    left: 0,
                                    right: 0,
                                    child: SwipeActionButtons(
                                      onLike: () => _runSwipeAnimation(true),
                                      onDislike: () =>
                                          _runSwipeAnimation(false),
                                      onChat: () {
                                        final authState = context
                                            .read<AuthCubit>()
                                            .state;
                                        if (authState is! AuthSuccess) {
                                          Navigator.of(
                                            context,
                                          ).push(OnboardingPage.route());
                                        }
                                      },
                                      enabled: !isInteractionDisabled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 70,
                            ), // Leave space for the action buttons at the bottom overlapping the stack
                          ],
                        ),
                      ),
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
  }
}

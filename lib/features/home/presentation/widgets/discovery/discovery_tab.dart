import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_cubit.dart';
import 'package:skillswap/features/home/presentation/widgets/discovery/swipe_action_buttons.dart';
import 'package:skillswap/features/home/presentation/widgets/discovery/swipeable_card.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:skillswap/features/auth/presentation/cubits/auth_state.dart';
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
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        if (state is DiscoveryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DiscoveryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (state is DiscoveryLoaded) {
          final users = state.users;
          final hasMoreUsers = _currentIndex < users.length;
          final isInteractionDisabled =
              _isAnimatingOffScreen || _showHeart || _showClose;

          if (!hasMoreUsers) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Color(0xFF0B6A7A),
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "You're all caught up!",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Come back later for more experts.",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final currentUser = users[_currentIndex];
          final screenHeight = MediaQuery.of(context).size.height;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<DiscoveryCubit>().fetchDiscoveryUsers(),
            color: const Color(0xFF0B6A7A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - kBottomNavigationBarHeight - 100,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'DISCOVER EXPERTS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: const Color(0xFF667085),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentIndex + 1}/${users.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: screenHeight * 0.65,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Next Card (Background)
                            if (_currentIndex + 1 < users.length)
                              Transform.scale(
                                scale: 0.9 +
                                    (_swipeOffset.dx.abs() / 2000).clamp(0, 0.1),
                                child: Opacity(
                                  opacity: 0.5 +
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
                                      opacity: _likeOpacityAnimation.value,
                                      child: Transform.scale(
                                        scale: _likeScaleAnimation.value,
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 100,
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
                                      opacity: _dislikeOpacityAnimation.value,
                                      child: Transform.rotate(
                                        angle: _dislikeShakeAnimation.value,
                                        child: Transform.scale(
                                          scale: _dislikeScaleAnimation.value,
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 100,
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
                              bottom: -35,
                              left: 0,
                              right: 0,
                              child: SwipeActionButtons(
                                onLike: () => _runSwipeAnimation(true),
                                onDislike: () => _runSwipeAnimation(false),
                                onChat: () {
                                  final authState =
                                      context.read<AuthCubit>().state;
                                  if (authState is! AuthSuccess) {
                                    Navigator.of(context)
                                        .push(OnboardingPage.route());
                                  }
                                },
                                enabled: !isInteractionDisabled,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

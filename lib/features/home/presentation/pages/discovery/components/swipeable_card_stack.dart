import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'swipe_action_buttons.dart';
import 'swipeable_card.dart';
import 'like_overlay.dart';
import 'dislike_overlay.dart';

class SwipeableCardStack extends StatefulWidget {
  final List<dynamic> users;
  final int currentIndex;
  final Function(bool isLiked) onSwiped;
  final Function(dynamic user) onChat;

  const SwipeableCardStack({
    super.key,
    required this.users,
    required this.currentIndex,
    required this.onSwiped,
    required this.onChat,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack>
    with TickerProviderStateMixin {
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

  @override
  void didUpdateWidget(covariant SwipeableCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _swipeOffset = Offset.zero;
      _swipeAngle = 0;
      _isAnimatingOffScreen = false;
    }
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
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
        widget.onSwiped(true);
      }
    });
  }

  void _triggerDislikeAnimation() {
    setState(() {
      _showClose = true;
      _showHeart = false;
    });
    _dislikeAnimationController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _showClose = false;
        });
        widget.onSwiped(false);
      }
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

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex >= widget.users.length) {
      return const SizedBox.shrink();
    }

    final currentUser = widget.users[widget.currentIndex];
    final isInteractionDisabled =
        _isAnimatingOffScreen || _showHeart || _showClose;

    final hPad = Responsive.contentHorizontalPadding(context);
    final topSpace = Responsive.valueFor<double>(
      context,
      compact: 16,
      mobile: 20,
      tablet: 22,
      tabletWide: 24,
      desktop: 24,
    );
    final bottomReserve = Responsive.valueFor<double>(
      context,
      compact: 56,
      mobile: 64,
      tablet: 68,
      tabletWide: 72,
      desktop: 76,
    );
    final actionBottom = Responsive.valueFor<double>(
      context,
      compact: -28,
      mobile: -34,
      tablet: -38,
      tabletWide: -40,
      desktop: -44,
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topSpace),
                  Expanded(
                    child: () {
                      final screenW = MediaQuery.sizeOf(context).width;
                      final availableW = screenW - (2 * hPad);
                      final maxCardW = Responsive.isTwoPane(context)
                          ? Responsive.valueFor<double>(
                              context,
                              compact: 360,
                              mobile: 400,
                              tablet: 460,
                              tabletWide: 520,
                              desktop: 560,
                            )
                          : availableW;
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxCardW),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Next Card (Background)
                              if (widget.currentIndex + 1 < widget.users.length)
                                AnimatedBuilder(
                          animation: _swipeAnimationController,
                          builder: (context, child) {
                            final offset = _isAnimatingOffScreen
                                ? _swipePositionAnimation.value
                                : _swipeOffset;
                            return Transform.scale(
                              scale:
                                  0.9 +
                                  (offset.dx.abs() / 2000).clamp(0, 0.1),
                              child: Opacity(
                                opacity:
                                    0.3 +
                                    (offset.dx.abs() / 1000).clamp(0, 0.5),
                                child: child,
                              ),
                            );
                          },
                          child: SwipeableCard(
                            user: widget.users[widget.currentIndex + 1],
                          ),
                        ),

                      // Top Card (Draggable)
                      GestureDetector(
                        onDoubleTap: _triggerLikeAnimation,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: AnimatedBuilder(
                          animation: _swipeAnimationController,
                          builder: (context, child) {
                            final offset = _isAnimatingOffScreen
                                ? _swipePositionAnimation.value
                                : _swipeOffset;
                            final angle = _isAnimatingOffScreen
                                ? _swipeAngleAnimation.value
                                : _swipeAngle;
                            return Transform.translate(
                              offset: offset,
                              child: Transform.rotate(
                                angle: angle,
                                child: child,
                              ),
                            );
                          },
                          child: SwipeableCard(user: currentUser),
                        ),
                      ),

                      // Like overlay
                      if (_showHeart)
                        LikeOverlay(
                          animationController: _likeAnimationController,
                          scaleAnimation: _likeScaleAnimation,
                          opacityAnimation: _likeOpacityAnimation,
                        ),

                      // Dislike overlay
                      if (_showClose)
                        DislikeOverlay(
                          animationController: _dislikeAnimationController,
                          scaleAnimation: _dislikeScaleAnimation,
                          opacityAnimation: _dislikeOpacityAnimation,
                          shakeAnimation: _dislikeShakeAnimation,
                        ),

                      // Action Buttons Row
                      Positioned(
                        bottom: actionBottom,
                        left: 0,
                        right: 0,
                        child: SwipeActionButtons(
                          onLike: () => _runSwipeAnimation(true),
                          onDislike: () => _runSwipeAnimation(false),
                          onChat: () => widget.onChat(currentUser),
                          enabled: !isInteractionDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              );
                    }(),
                  ),
                  SizedBox(height: bottomReserve),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

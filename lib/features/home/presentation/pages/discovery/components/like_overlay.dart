import 'package:flutter/material.dart';

class LikeOverlay extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const LikeOverlay({
    super.key,
    required this.animationController,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFCA8A04).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCA8A04).withValues(alpha: 0.5),
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
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DislikeOverlay extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final Animation<double> shakeAnimation;

  const DislikeOverlay({
    super.key,
    required this.animationController,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnimation.value,
            child: Transform.rotate(
              angle: shakeAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
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
          );
        },
      ),
    );
  }
}

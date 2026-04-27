import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.isLoading = false,
    this.height = 64, // Increased height for premium feel
    this.borderRadius = 24, // Matches the new card radius
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppColors.primary;
    const secondaryColor = AppColors.primaryDark;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final resolvedHeight = widget.height
        .clamp(
          Responsive.valueFor<double>(
            context,
            compact: 52,
            mobile: 56,
            tablet: 60,
            tabletWide: 64,
            desktop: 64,
          ),
          72,
        )
        .toDouble();
    final iconSize = (22 * textScale).clamp(18, 26).toDouble();
    final loaderSize = (24 * textScale).clamp(20, 28).toDouble();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading ? null : widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: BoxConstraints(minHeight: resolvedHeight),
            width: double.infinity, // Default to full width for auth buttons
            decoration: _getDecoration(accentColor, secondaryColor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            height: loaderSize,
                            width: loaderSize,
                            child: const CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.leadingIcon != null) ...[
                                Icon(
                                  widget.leadingIcon,
                                  color: AppColors.textPrimary,
                                  size: iconSize,
                                ),
                                const SizedBox(width: 16),
                              ],
                              Text(
                                widget.label,
                                style: widget.variant == AppButtonVariant.primary
                                    ? AppTextStyles.buttonPrimary
                                    : AppTextStyles.buttonSecondary,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(Color primary, Color secondary) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.borderDefault),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.borderSubtle),
        );
    }
  }

}

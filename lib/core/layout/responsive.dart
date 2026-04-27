import 'package:flutter/material.dart';
import 'breakpoints.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.compact;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet &&
      MediaQuery.sizeOf(context).width < AppBreakpoints.tabletWide;

  static bool isTabletWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tabletWide &&
      MediaQuery.sizeOf(context).width < AppBreakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double contentMaxWidthFor(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTabletWide(context)) return 1000;
    if (isTablet(context)) return 860;
    return double.infinity;
  }

  static bool isTwoPane(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tabletWide;

  static T valueFor<T>(
    BuildContext context, {
    required T compact,
    required T mobile,
    T? tablet,
    T? tabletWide,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTabletWide(context) && tabletWide != null) return tabletWide;
    if (isTablet(context) && tablet != null) return tablet;
    if (isCompact(context)) return compact;
    return mobile;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 48.0);
    if (isTabletWide(context)) return const EdgeInsets.symmetric(horizontal: 36.0);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 28.0);
    if (isCompact(context)) return const EdgeInsets.symmetric(horizontal: 16.0);
    return const EdgeInsets.symmetric(horizontal: 20.0);
  }

  static double contentHorizontalPadding(BuildContext context) {
    return screenPadding(context).horizontal / 2;
  }

  /// Two-pane chat / hub side rail: fraction of width, clamped for readability.
  static double chatSideRailWidth(BuildContext context) {
    final w = screenWidth(context);
    return (w * 0.32).clamp(260.0, 420.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= AppBreakpoints.tablet && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

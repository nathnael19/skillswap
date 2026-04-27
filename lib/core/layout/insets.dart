import 'package:flutter/widgets.dart';

/// Shared spacing tokens (dp).
///
/// Use these instead of scattering magic numbers, especially where tablet
/// layouts need more breathing room.
class AppInsets {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screenHPadding = EdgeInsets.symmetric(horizontal: xl);
}


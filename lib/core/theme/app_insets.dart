import 'package:flutter/material.dart';

class AppInsets {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.all(xl);
  static const EdgeInsets horizontalScreenPadding = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets verticalScreenPadding = EdgeInsets.symmetric(vertical: xl);
}

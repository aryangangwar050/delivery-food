import 'package:flutter/widgets.dart';

/// Simple responsive size helper. Call `SizeConfig.init(context)` at the start of
/// your widget build method (once per widget) and use `SizeConfig.fs(value)` to
/// get a font-size scaled for the current screen width.
class SizeConfig {
  SizeConfig._();

  static double _scale = 1.0;

  /// Base design width used to compute scale factor. Choose the width the
  /// designs were created for (commonly 375.0 for iPhone 11 / common designs).
  static const double baseWidth = 375.0;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _scale = mq.size.width / baseWidth;
  }

  /// Returns a scaled font size.
  static double fs(double size) => size * _scale;

  /// Returns a scaled size for layouts/padding.
  static double scale(double size) => size * _scale;
}

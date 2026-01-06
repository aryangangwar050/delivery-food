import 'package:flutter/material.dart';

import '../../utils/color_res.dart';
import '../../utils/size_config.dart';

/// A simple, reusable splash screen widget.
///
/// Contract:
/// - Inputs: optional [duration], [nextRoute] or an [onInitializationComplete] callback, optional [logo] widget.
/// - Output: after [duration] it either calls [onInitializationComplete] or navigates to [nextRoute] if provided.
/// - Error modes: If no [onInitializationComplete] and no [nextRoute] are provided, the splash simply hides after [duration].
///
/// Usage:
/// ```dart
/// SplashScreen(
///   duration: Duration(seconds: 3),
///   nextRoute: '/home',
/// )
/// ```
class SplashScreen extends StatefulWidget {
  /// How long the splash screen remains visible.
  final Duration duration;

  /// If provided, the splash screen will navigate to this named route after [duration].
  final String? nextRoute;

  /// Optional callback invoked when initialization finishes (before navigation).
  final VoidCallback? onInitializationComplete;

  /// Optional widget to display as the app logo. If null, an icon fallback is shown.
  final Widget? logo;

  /// Optional background gradient. If null, a default gradient is used.
  final Gradient? backgroundGradient;

  const SplashScreen({
    Key? key,
    this.duration = const Duration(seconds: 3),
    this.nextRoute,
    this.onInitializationComplete,
    this.logo,
    this.backgroundGradient,
  }) : super(key: key);

  /// Helpful constant route name if you want to register it in your routes table.
  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  static const Duration _minDisplayDuration = Duration(seconds: 3);
  late final Duration _displayDuration;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the fade-in animation.
    _controller.forward();

  // Ensure the splash shows for at least [_minDisplayDuration].
  _displayDuration = widget.duration >= _minDisplayDuration
    ? widget.duration
    : _minDisplayDuration;

  // After the configured (or enforced-minimum) duration, call the completion callback or navigate.
  Future.delayed(_displayDuration, () {
      if (!mounted) return;

      // call callback first
      widget.onInitializationComplete?.call();

      if (widget.nextRoute != null) {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute!);
      } else {
        // If no route provided, fade out the splash gracefully.
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    if (widget.logo != null) return widget.logo!;

    // Try to show an asset if available; gracefully fallback to an Icon.
    return Image.asset(
      'assets/images/logo.png',
      height: 120,
      width: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.fastfood,
        size: 96,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final gradient = widget.backgroundGradient ?? const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorRes.primaryVariant, ColorRes.primary],
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.scale(8)),
                SizedBox(
                  height: SizeConfig.scale(120),
                  width: SizeConfig.scale(120),
                  child: _buildLogo(),
                ),
                SizedBox(height: SizeConfig.scale(20)),
                Text(
                  'Food Delivery',
                  style: TextStyle(
                    color: ColorRes.white,
                    fontSize: SizeConfig.fs(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.scale(28)),
                SizedBox(
                  height: SizeConfig.scale(24),
                  width: SizeConfig.scale(24),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ColorRes.white70),
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

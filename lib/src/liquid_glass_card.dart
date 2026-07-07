import 'package:flutter/material.dart';

import 'liquid_glass_settings.dart';
import 'platform_glass.dart';

/// A glass-effect container card.
///
/// On iOS 26+ renders via native SwiftUI `.glassEffect()`.
/// On Android and older iOS uses a blur + tint fallback.
///
/// ```dart
/// LiquidGlassCard(
///   child: Padding(
///     padding: EdgeInsets.all(20),
///     child: Text('Hello, Glass!'),
///   ),
/// )
/// ```
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.settings = LiquidGlassSettings.matteLight,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final LiquidGlassSettings settings;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;

  /// Inner padding applied to [child].
  final EdgeInsetsGeometry padding;

  /// Outer margin around the card.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: PlatformGlass(
        borderRadius: borderRadius,
        settings: settings,
        width: width,
        height: height,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

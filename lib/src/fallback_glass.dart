import 'dart:ui';

import 'package:flutter/material.dart';

import 'liquid_glass_settings.dart';

/// Pure-Flutter glassmorphism renderer.
///
/// Used on Android. It renders adaptive matte glass when [tintColor] is null,
/// or coloured glass when the caller provides a tint.
class FallbackGlass extends StatelessWidget {
  const FallbackGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.settings,
    this.useSharedBackdrop = true,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final LiquidGlassSettings settings;

  /// Whether this surface can share one backdrop pass with sibling glass
  /// surfaces inside [LiquidGlassBackdropGroup].
  ///
  /// Keep this disabled for floating surfaces that can overlap scroll content
  /// (for example bottom navigation bars). Overlapping grouped backdrop filters
  /// can visually cancel each other and make the glass look transparent during
  /// Android overscroll.
  final bool useSharedBackdrop;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = settings.tintColor ??
        (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F8FA));
    final highlight = settings.tintColor == null
        ? Colors.white.withValues(alpha: isDark ? 0.06 : 0.22)
        : tint.withValues(alpha: isDark ? 0.16 : 0.20);

    final blurSigma =
        settings.blurSigma.clamp(0.0, settings.androidBlurSigma).toDouble();
    final glassContent = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // Tint layer
        color: tint.withValues(alpha: settings.tintOpacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: settings.borderOpacity),
          width: settings.borderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            highlight,
            Colors.white.withValues(alpha: isDark ? 0.02 : 0.05),
          ],
        ),
      ),
      child: child,
    );
    final filteredContent = blurSigma == 0
        ? glassContent
        : _SharedBackdropFilter(
            sigma: blurSigma,
            enabled: useSharedBackdrop,
            child: glassContent,
          );

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: settings.shadowOpacity),
              blurRadius: settings.shadowBlurRadius,
              offset: settings.shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: filteredContent,
        ),
      ),
    );
  }
}

/// Shares backdrop input between non-overlapping fallback surfaces.
///
/// Wrap a screen or section containing several Liquid Glass widgets with
/// [LiquidGlassBackdropGroup] to reduce Android blur passes to one.
class LiquidGlassBackdropGroup extends StatelessWidget {
  const LiquidGlassBackdropGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => BackdropGroup(child: child);
}

/// Scroll behavior for Android glass-heavy screens.
///
/// Android's default overscroll glow/stretch can temporarily alter backdrop
/// sampling at the start and end of scrollable content. Use this behavior on
/// screens that contain fallback glass surfaces to keep the glass tint stable.
class LiquidGlassScrollBehavior extends MaterialScrollBehavior {
  const LiquidGlassScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _SharedBackdropFilter extends StatelessWidget {
  const _SharedBackdropFilter({
    required this.sigma,
    required this.enabled,
    required this.child,
  });

  final double sigma;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final filter = ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    if (enabled && BackdropGroup.of(context) != null) {
      return BackdropFilter.grouped(filter: filter, child: child);
    }
    return BackdropFilter(filter: filter, child: child);
  }
}

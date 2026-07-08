import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_settings.dart';
import 'fallback_glass.dart';

/// Determines whether this widget will use the native iOS glass surface.
///
/// The native view itself uses the OS availability check for Liquid Glass. On
/// iOS versions before Liquid Glass is available, it provides a native material
/// fallback. Android always uses [FallbackGlass].
bool get isNativeLiquidGlassSupported {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

/// Core widget that routes to the native iOS PlatformView or Android's
/// cross-platform matte-glass renderer.
///
/// You typically don't use this directly — prefer [LiquidGlassCard],
/// [LiquidGlassButton], or [LiquidGlassNavBar].
class PlatformGlass extends StatelessWidget {
  const PlatformGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.settings = LiquidGlassSettings.matteLight,
    this.useSharedBackdrop = true,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final LiquidGlassSettings settings;

  /// Whether Android fallback surfaces can use [BackdropFilter.grouped].
  ///
  /// Disable this for floating surfaces that may overlap other glass widgets.
  final bool useSharedBackdrop;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (isNativeLiquidGlassSupported) {
      return _NativeLiquidGlass(
        borderRadius: borderRadius,
        settings: settings,
        width: width,
        height: height,
        child: child,
      );
    }
    return FallbackGlass(
      borderRadius: borderRadius,
      settings: settings,
      useSharedBackdrop: useSharedBackdrop,
      width: width,
      height: height,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Native iOS implementation via UiKitView + SwiftUI
// ---------------------------------------------------------------------------

class _NativeLiquidGlass extends StatelessWidget {
  const _NativeLiquidGlass({
    required this.child,
    required this.borderRadius,
    required this.settings,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final LiquidGlassSettings settings;
  final double? width;
  final double? height;

  Map<String, dynamic> get _creationParams => {
        'cornerRadius': borderRadius.topLeft.x,
        'tintColorHex': settings.tintColor != null
            ? '#${settings.tintColor!.toARGB32().toRadixString(16).padLeft(8, '0')}'
            : null,
        'tintOpacity': settings.tintOpacity,
        'blurSigma': settings.blurSigma,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        // Let the Flutter child determine the height when this widget is used
        // in a vertical scroll view. StackFit.expand would pass an unbounded
        // height to both children, which prevents the child from being laid
        // out. The native view is positioned after the stack has a real size.
        fit: StackFit.passthrough,
        children: [
          // The native SwiftUI glass surface sits behind the Flutter child
          Positioned.fill(
            child: UiKitView(
              viewType: 'flutter_liquid_glass_kit/glass_surface',
              creationParams: _creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          // Flutter child renders on top (hit-testing preserved)
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Shared visual configuration for all Liquid Glass widgets.
///
/// On iOS, the supported values are forwarded to the native glass surface.
/// On Android, they control the Flutter matte-glass fallback. Set [tintColor]
/// to use a coloured glass surface; leave it null for adaptive matte glass.
class LiquidGlassSettings {
  const LiquidGlassSettings({
    this.tintColor,
    this.tintOpacity = 0.15,
    this.blurSigma = 20.0,
    this.androidBlurSigma = 12.0,
    this.borderOpacity = 0.25,
    this.borderWidth = 1.0,
    this.shadowOpacity = 0.12,
    this.shadowBlurRadius = 16.0,
    this.shadowOffset = const Offset(0, 4),
  });

  /// Optional colour overlaid on the glass surface.
  ///
  /// On Android this is the colour requested by the caller. If it is omitted,
  /// the fallback selects an adaptive light or dark matte colour.
  final Color? tintColor;

  /// Opacity of the tint layer (0.0 – 1.0).
  final double tintOpacity;

  /// Gaussian blur radius applied to content behind the glass.
  final double blurSigma;

  /// Maximum blur used by the Android fallback renderer.
  ///
  /// Android backdrop blurs are substantially more expensive than the native
  /// iOS material. The lower default keeps scrolling and selection animations
  /// responsive while retaining the matte-glass appearance. Set to `0` to
  /// disable Android backdrop blur entirely.
  final double androidBlurSigma;

  /// Opacity of the glass border highlight.
  final double borderOpacity;

  /// Width of the border stroke in logical pixels.
  final double borderWidth;

  /// Opacity of the drop shadow.
  final double shadowOpacity;

  /// Blur radius of the drop shadow.
  final double shadowBlurRadius;

  /// Offset of the drop shadow.
  final Offset shadowOffset;

  /// Reasonable defaults matching the iOS 26 matte-glass look.
  static const LiquidGlassSettings matteLight = LiquidGlassSettings(
    tintColor: Colors.white,
    tintOpacity: 0.18,
    blurSigma: 24,
    borderOpacity: 0.30,
  );

  static const LiquidGlassSettings matteDark = LiquidGlassSettings(
    tintColor: Color(0xFF1C1C1E),
    tintOpacity: 0.55,
    blurSigma: 24,
    borderOpacity: 0.15,
  );

  /// Resolves component settings from a local override, the nearest shared
  /// settings scope, or [matteLight] when neither is supplied.
  static LiquidGlassSettings resolve(
    BuildContext context,
    LiquidGlassSettings? localSettings,
  ) {
    return localSettings ??
        LiquidGlassSettingsScope.maybeOf(context) ??
        matteLight;
  }

  LiquidGlassSettings copyWith({
    Color? tintColor,
    double? tintOpacity,
    double? blurSigma,
    double? androidBlurSigma,
    double? borderOpacity,
    double? borderWidth,
    double? shadowOpacity,
    double? shadowBlurRadius,
    Offset? shadowOffset,
  }) {
    return LiquidGlassSettings(
      tintColor: tintColor ?? this.tintColor,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      blurSigma: blurSigma ?? this.blurSigma,
      androidBlurSigma: androidBlurSigma ?? this.androidBlurSigma,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LiquidGlassSettings &&
            tintColor == other.tintColor &&
            tintOpacity == other.tintOpacity &&
            blurSigma == other.blurSigma &&
            androidBlurSigma == other.androidBlurSigma &&
            borderOpacity == other.borderOpacity &&
            borderWidth == other.borderWidth &&
            shadowOpacity == other.shadowOpacity &&
            shadowBlurRadius == other.shadowBlurRadius &&
            shadowOffset == other.shadowOffset;
  }

  @override
  int get hashCode => Object.hash(
        tintColor,
        tintOpacity,
        blurSigma,
        androidBlurSigma,
        borderOpacity,
        borderWidth,
        shadowOpacity,
        shadowBlurRadius,
        shadowOffset,
      );
}

/// Provides baseline settings to descendant Liquid Glass components.
///
/// [LiquidGlassBackdropGroup] creates this scope when its `settings` argument
/// is supplied. This widget is also public for layouts that need shared
/// settings without backdrop grouping.
class LiquidGlassSettingsScope extends InheritedWidget {
  const LiquidGlassSettingsScope({
    super.key,
    required this.settings,
    required super.child,
  });

  final LiquidGlassSettings settings;

  static LiquidGlassSettings? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LiquidGlassSettingsScope>()
        ?.settings;
  }

  @override
  bool updateShouldNotify(LiquidGlassSettingsScope oldWidget) {
    return settings != oldWidget.settings;
  }
}

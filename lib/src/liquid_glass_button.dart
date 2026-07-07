import 'package:flutter/material.dart';

import 'liquid_glass_settings.dart';
import 'platform_glass.dart';

/// A pressable glass-effect button.
///
/// Wraps any [child] in the Liquid Glass surface and handles tap,
/// scale feedback, and an optional loading state.
///
/// ```dart
/// LiquidGlassButton(
///   onPressed: () => print('tapped'),
///   child: Text('Get Started'),
/// )
/// ```
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.settings = LiquidGlassSettings.matteLight,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.isLoading = false,
    this.pressScaleFactor = 0.96,
    this.animationDuration = const Duration(milliseconds: 120),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final LiquidGlassSettings settings;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  /// Shows a [CircularProgressIndicator] in place of [child] when `true`.
  final bool isLoading;

  /// Scale factor applied while the button is pressed (0.0 – 1.0).
  final double pressScaleFactor;

  final Duration animationDuration;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScaleFactor,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _scaleController.duration = widget.animationDuration;
    }
    if (oldWidget.pressScaleFactor != widget.pressScaleFactor) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.pressScaleFactor,
      ).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
    }
  }

  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _isEnabled,
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => _scaleController.forward() : null,
        onTap: _isEnabled ? widget.onPressed : null,
        onTapUp: _isEnabled ? (_) => _scaleController.reverse() : null,
        onTapCancel: _isEnabled ? _onTapCancel : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: PlatformGlass(
            borderRadius: widget.borderRadius,
            settings: _isEnabled
                ? widget.settings
                : widget.settings
                    .copyWith(tintOpacity: widget.settings.tintOpacity * 0.5),
            child: Padding(
              padding: widget.padding,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'liquid_glass_settings.dart';
import 'platform_glass.dart';

/// A floating glass bottom navigation bar.
///
/// Floats above the content, positioned with [bottomPadding] from the safe
/// area. On iOS 26+ this renders via the native SwiftUI glass surface.
///
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       YourContent(),
///       LiquidGlassNavBar(
///         currentIndex: _index,
///         onTap: (i) => setState(() => _index = i),
///         items: [
///           LiquidGlassNavItem(icon: Icons.home, label: 'Home'),
///           LiquidGlassNavItem(icon: Icons.search, label: 'Search'),
///           LiquidGlassNavItem(icon: Icons.person, label: 'Profile'),
///         ],
///       ),
///     ],
///   ),
/// )
/// ```
class LiquidGlassNavBar extends StatelessWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.settings = LiquidGlassSettings.matteLight,
    this.height = 64,
    this.horizontalPadding = 20,
    this.bottomPadding = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x99FFFFFF),
    this.indicatorColor = const Color(0x33FFFFFF),
    this.showLabels = true,
  })  : assert(items.length > 1, 'A navigation bar needs at least two items.'),
        assert(currentIndex >= 0 && currentIndex < items.length),
        assert(height > 0),
        assert(horizontalPadding >= 0),
        assert(bottomPadding >= 0);

  final List<LiquidGlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final LiquidGlassSettings settings;

  /// Height of the nav bar surface.
  final double height;

  /// Horizontal inset from screen edges.
  final double horizontalPadding;

  /// Spacing above the safe-area bottom.
  final double bottomPadding;

  final BorderRadius borderRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;

  /// Whether to show text labels below icons.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final navBar = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? _NativeIOSNavBar(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            height: height,
            settings: settings,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            indicatorColor: indicatorColor,
            showLabels: showLabels,
          )
        : _LiquidGlassDock(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            height: height,
            settings: settings,
            borderRadius: borderRadius,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            indicatorColor: indicatorColor,
            showLabels: showLabels,
          );

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: safeBottom + bottomPadding,
      child: navBar,
    );
  }
}

class _NativeIOSNavBar extends StatefulWidget {
  const _NativeIOSNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.height,
    required this.settings,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    required this.showLabels,
  });

  final List<LiquidGlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final LiquidGlassSettings settings;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final bool showLabels;

  @override
  State<_NativeIOSNavBar> createState() => _NativeIOSNavBarState();
}

class _NativeIOSNavBarState extends State<_NativeIOSNavBar> {
  MethodChannel? _channel;

  Map<String, dynamic> get _creationParams => {
        'items': [
          for (final item in widget.items)
            {
              'label': item.label,
              'badge': item.badge,
              'iosSystemImage': item.iosSystemImage,
              'iosSelectedSystemImage': item.iosSelectedSystemImage,
              'iconCodePoint': item.icon.codePoint,
              'activeIconCodePoint': item.activeIcon?.codePoint,
            },
        ],
        'currentIndex': widget.currentIndex,
        'tintColorHex': _hex(widget.settings.tintColor ?? Colors.black),
        'tintOpacity': widget.settings.tintOpacity,
        'activeColorHex': _hex(widget.activeColor),
        'inactiveColorHex': _hex(widget.inactiveColor),
        'indicatorColorHex': _hex(widget.indicatorColor),
        'showLabels': widget.showLabels,
      };

  @override
  void didUpdateWidget(covariant _NativeIOSNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _channel?.invokeMethod<void>('setCurrentIndex', widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: UiKitView(
        viewType: 'flutter_liquid_glass_kit/native_nav_bar',
        creationParams: _creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          final channel =
              MethodChannel('flutter_liquid_glass_kit/native_nav_bar_$id');
          channel.setMethodCallHandler((call) async {
            if (call.method == 'tap') {
              final index = call.arguments as int;
              HapticFeedback.selectionClick();
              widget.onTap(index);
            }
          });
          _channel = channel;
        },
      ),
    );
  }

  String _hex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
  }
}

/// Shared floating dock. [PlatformGlass] supplies native Liquid Glass on iOS
/// and the matte/tinted renderer on Android; the selection motion stays the
/// same on both platforms.
class _LiquidGlassDock extends StatefulWidget {
  const _LiquidGlassDock({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.height,
    required this.settings,
    required this.borderRadius,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    required this.showLabels,
  });

  final List<LiquidGlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final LiquidGlassSettings settings;
  final BorderRadius borderRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final bool showLabels;

  @override
  State<_LiquidGlassDock> createState() => _LiquidGlassDockState();
}

class _LiquidGlassDockState extends State<_LiquidGlassDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _fromIndex;
  late int _toIndex;

  static const _duration = Duration(milliseconds: 550);
  // How much the blob grows vertically (px) at the peak of the stretch.
  static const double _maxVerticalStretch = 6;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..value = 1;
  }

  @override
  void didUpdateWidget(covariant _LiquidGlassDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromIndex = _currentBlobIndex();
      _toIndex = widget.currentIndex;
      _controller
        ..stop()
        ..value = 0
        ..forward();
    }
  }

  // If a tap interrupts an in-flight animation, start the new leg from
  // wherever the blob visually is right now instead of snapping back.
  int _currentBlobIndex() {
    if (!_controller.isAnimating) return _toIndex;
    final t = Curves.easeOutCubic.transform(_controller.value);
    return (_fromIndex + (_toIndex - _fromIndex) * t).round();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Computes the current geometry of the liquid indicator.
  ///
  /// The center eases from [_fromIndex] to [_toIndex]. Independently, a
  /// bell-shaped stretch factor (0 at start/end, peak at the midpoint)
  /// grows the blob vertically, then settles back to the resting pill shape.
  Rect _blobRect(double itemWidth, double dockHeight) {
    final t = _controller.value;
    final positionT = Curves.easeOutCubic.transform(t);

    final fromCenter = (_fromIndex + 0.5) * itemWidth;
    final toCenter = (_toIndex + 0.5) * itemWidth;
    final center = _lerp(fromCenter, toCenter, positionT);

    // Bell curve: 0 at t=0 and t=1, 1 at t=0.5.
    final stretch = math.sin(math.pi * t);

    // Scale the stretch by travel distance so an adjacent-tab tap doesn't
    // balloon as dramatically as a jump across the whole dock.
    final travel = (toCenter - fromCenter).abs();
    final travelFactor = (travel / (itemWidth * 1.5)).clamp(0.35, 1.0);

    final restWidth = itemWidth - 8;
    final restHeight = dockHeight - 8;

    final width = restWidth;
    final height = (restHeight + _maxVerticalStretch * stretch * travelFactor)
        .clamp(restHeight, dockHeight - 4);

    final left = center - width / 2;
    final top = (dockHeight - height) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    final dockSettings = widget.settings.tintColor == null
        ? widget.settings.copyWith(tintColor: Colors.black, tintOpacity: 0.26)
        : widget.settings;

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: IgnorePointer(
              child: PlatformGlass(
                borderRadius: widget.borderRadius,
                settings: dockSettings,
                useSharedBackdrop: false,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / widget.items.length;
              return Stack(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final rect = _blobRect(itemWidth, widget.height);
                      return Positioned.fromRect(
                        rect: rect,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                widget.indicatorColor.withValues(alpha: 0.28),
                            borderRadius:
                                BorderRadius.circular(rect.height / 2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      for (var index = 0; index < widget.items.length; index++)
                        Expanded(
                          child: _DockItem(
                            item: widget.items[index],
                            isActive: index == widget.currentIndex,
                            activeColor: widget.activeColor,
                            inactiveColor: widget.inactiveColor,
                            showLabel: widget.showLabels,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onTap(index);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.showLabel,
    required this.onTap,
  });

  final LiquidGlassNavItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    final icon = isActive ? (item.activeIcon ?? item.icon) : item.icon;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                scale: isActive ? 1.08 : 1,
                child: Icon(icon, color: color, size: 25),
              ),
              if (item.badge != null && item.badge! > 0)
                Positioned(
                  top: -5,
                  right: -9,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${item.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (showLabel) ...[
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single item descriptor for [LiquidGlassNavBar].
class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.iosSystemImage,
    this.iosSelectedSystemImage,
  });

  final IconData icon;

  /// Optional icon shown when this item is selected.
  final IconData? activeIcon;

  final String label;

  /// Optional badge count (null = hidden).
  final int? badge;

  /// Optional SF Symbol name used by the native iOS tab bar.
  ///
  /// If omitted, the plugin maps common Material icons to SF Symbols.
  final String? iosSystemImage;

  /// Optional selected-state SF Symbol name used by the native iOS tab bar.
  final String? iosSelectedSystemImage;
}

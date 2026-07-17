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
///           LiquidGlassNavItem(
///             icon: Icons.person,
///             label: 'Profile',
///             androidIcon: CircleAvatar(child: Text('P')),
///           ),
///         ],
///       ),
///     ],
///   ),
/// )
/// ```
class LiquidGlassNavBar extends StatelessWidget {
  /// Creates a controlled floating navigation bar.
  ///
  /// Place this widget as a child of a [Stack] because it returns a
  /// [Positioned] surface. The selected item is controlled by [currentIndex];
  /// [onTap] must update that value in the parent. On the Flutter fallback,
  /// users can hold and drag the indicator to preview items before releasing.
  ///
  /// When `settings` is omitted, the nearest shared settings scope is used.
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    LiquidGlassSettings? settings,
    this.height = 64,
    this.horizontalPadding = 20,
    this.bottomPadding = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x99FFFFFF),
    this.indicatorColor = const Color(0x33FFFFFF),
    this.showLabels = true,
  })  : _settings = settings,
        assert(items.length > 1, 'A navigation bar needs at least two items.'),
        assert(currentIndex >= 0 && currentIndex < items.length),
        assert(height > 0),
        assert(horizontalPadding >= 0),
        assert(bottomPadding >= 0);

  /// Items displayed from left to right.
  ///
  /// At least two items are required.
  final List<LiquidGlassNavItem> items;

  /// Index of the currently selected item.
  final int currentIndex;

  /// Called with the selected index after a tap or completed drag.
  ///
  /// Cancelling a drag does not call this callback.
  final ValueChanged<int> onTap;
  final LiquidGlassSettings? _settings;

  /// The locally supplied settings, or [LiquidGlassSettings.matteLight] when
  /// no local settings were supplied.
  ///
  /// The effective inherited value is resolved during build.
  LiquidGlassSettings get settings =>
      _settings ?? LiquidGlassSettings.matteLight;

  /// Height of the navigation surface in logical pixels.
  final double height;

  /// Horizontal inset from the containing [Stack]'s left and right edges.
  final double horizontalPadding;

  /// Additional spacing above the device safe-area bottom.
  final double bottomPadding;

  /// Shape of the fallback navigation surface.
  final BorderRadius borderRadius;

  /// Color inherited by the selected icon, widget, and label.
  final Color activeColor;

  /// Color inherited by unselected icons, widgets, and labels.
  final Color inactiveColor;

  /// Base color used for the animated fallback selection indicator.
  final Color indicatorColor;

  /// Whether labels are displayed below icons on both renderers.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final effectiveSettings = LiquidGlassSettings.resolve(context, _settings);
    final navBar = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? _NativeIOSNavBar(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            height: height,
            settings: effectiveSettings,
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
            settings: effectiveSettings,
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
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _holdController;
  late final Listenable _indicatorAnimation;
  late final ValueNotifier<double?> _dragCenter;
  late final ValueNotifier<int?> _dragIndex;
  late double _fromPosition;
  late double _toPosition;

  static const _duration = Duration(milliseconds: 550);
  static const _holdDuration = Duration(milliseconds: 180);
  static const double _holdWidthExpansion = 16;
  static const double _holdHeightExpansion = 14;
  // Long jumps briefly lift the indicator beyond the dock, like the native
  // Liquid Glass selection motion.
  static const double _maxVerticalStretch = 18;

  @override
  void initState() {
    super.initState();
    _fromPosition = widget.currentIndex.toDouble();
    _toPosition = widget.currentIndex.toDouble();
    _dragCenter = ValueNotifier(null);
    _dragIndex = ValueNotifier(null);
    _controller = AnimationController(vsync: this, duration: _duration)
      ..value = 1;
    _holdController = AnimationController(
      vsync: this,
      duration: _holdDuration,
      reverseDuration: const Duration(milliseconds: 140),
    );
    _indicatorAnimation = Listenable.merge([
      _controller,
      _holdController,
      _dragCenter,
    ]);
  }

  @override
  void didUpdateWidget(covariant _LiquidGlassDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromPosition = _currentBlobPosition();
      _toPosition = widget.currentIndex.toDouble();
      _controller
        ..stop()
        ..value = 0
        ..forward();
    }
  }

  // If a tap interrupts an in-flight animation, start the new leg from
  // wherever the blob visually is right now instead of snapping back.
  double _currentBlobPosition() {
    if (!_controller.isAnimating) return _toPosition;
    final t = Curves.easeOutCubic.transform(_controller.value);
    return _lerp(_fromPosition, _toPosition, t);
  }

  double _clampDragCenter(
    double center,
    double itemWidth,
    double dockWidth,
  ) {
    return center.clamp(itemWidth / 2, dockWidth - itemWidth / 2);
  }

  int _indexForCenter(double center, double itemWidth) {
    return (center / itemWidth).floor().clamp(0, widget.items.length - 1);
  }

  void _startDrag(double center, double itemWidth, double dockWidth) {
    _controller.stop();
    _holdController.forward();
    final clamped = _clampDragCenter(center, itemWidth, dockWidth);
    _dragIndex.value = _indexForCenter(clamped, itemWidth);
    _dragCenter.value = clamped;
  }

  void _updateDrag(double center, double itemWidth, double dockWidth) {
    final clamped = _clampDragCenter(center, itemWidth, dockWidth);
    final index = _indexForCenter(clamped, itemWidth);
    if (index != _dragIndex.value) {
      HapticFeedback.selectionClick();
      _dragIndex.value = index;
    }
    _dragCenter.value = clamped;
  }

  void _finishDrag(double itemWidth, {required bool selectItem}) {
    final center = _dragCenter.value;
    if (center == null) return;

    final target =
        selectItem ? _indexForCenter(center, itemWidth) : widget.currentIndex;
    _fromPosition = center / itemWidth - 0.5;
    _toPosition = target.toDouble();
    _dragIndex.value = null;
    _dragCenter.value = null;
    _holdController.reverse();
    _controller
      ..value = 0
      ..forward();

    if (selectItem && target != widget.currentIndex) {
      widget.onTap(target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _holdController.dispose();
    _dragCenter.dispose();
    _dragIndex.dispose();
    super.dispose();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Computes the current geometry of the liquid indicator.
  ///
  /// The center eases from [_fromPosition] to [_toPosition]. Independently, a
  /// bell-shaped stretch factor (0 at start/end, peak at the midpoint)
  /// grows the blob vertically, then settles back to the resting pill shape.
  Rect _blobRect(double itemWidth, double dockHeight) {
    final dragCenter = _dragCenter.value;
    if (dragCenter != null) {
      final restWidth = itemWidth - 8;
      final restHeight = dockHeight - 8;
      return Rect.fromCenter(
        center: Offset(dragCenter, dockHeight / 2),
        width: restWidth + _holdWidthExpansion * _holdController.value,
        height: restHeight + _holdHeightExpansion * _holdController.value,
      );
    }

    final t = _controller.value;
    final positionT = Curves.easeOutCubic.transform(t);

    final fromCenter = (_fromPosition + 0.5) * itemWidth;
    final toCenter = (_toPosition + 0.5) * itemWidth;
    final center = _lerp(fromCenter, toCenter, positionT);

    // Bell curve: 0 at t=0 and t=1, 1 at t=0.5.
    final stretch = math.sin(math.pi * t);

    // Scale the stretch by travel distance so an adjacent-tab tap doesn't
    // balloon as dramatically as a jump across the whole dock.
    final travel = (toCenter - fromCenter).abs();
    final travelFactor = (travel / (itemWidth * 1.5)).clamp(0.65, 1.0);

    final restWidth = itemWidth - 8;
    final restHeight = dockHeight - 8;

    final width = restWidth + _holdWidthExpansion * _holdController.value;
    final height = restHeight +
        _maxVerticalStretch * stretch * travelFactor +
        _holdHeightExpansion * _holdController.value;

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
        clipBehavior: Clip.none,
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
              return Listener(
                onPointerCancel: (_) =>
                    _finishDrag(itemWidth, selectItem: false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) => _startDrag(
                    details.localPosition.dx,
                    itemWidth,
                    constraints.maxWidth,
                  ),
                  onHorizontalDragUpdate: (details) => _updateDrag(
                    details.localPosition.dx,
                    itemWidth,
                    constraints.maxWidth,
                  ),
                  onHorizontalDragEnd: (_) =>
                      _finishDrag(itemWidth, selectItem: true),
                  onHorizontalDragCancel: () =>
                      _finishDrag(itemWidth, selectItem: false),
                  onLongPressStart: (details) => _startDrag(
                    details.localPosition.dx,
                    itemWidth,
                    constraints.maxWidth,
                  ),
                  onLongPressMoveUpdate: (details) => _updateDrag(
                    details.localPosition.dx,
                    itemWidth,
                    constraints.maxWidth,
                  ),
                  onLongPressEnd: (_) =>
                      _finishDrag(itemWidth, selectItem: true),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _indicatorAnimation,
                        builder: (context, _) {
                          final rect = _blobRect(itemWidth, widget.height);
                          return Positioned.fromRect(
                            rect: rect,
                            child: DecoratedBox(
                              key: const ValueKey('liquid-glass-nav-indicator'),
                              decoration: BoxDecoration(
                                color: widget.indicatorColor
                                    .withValues(alpha: 0.28),
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
                      ValueListenableBuilder<int?>(
                        valueListenable: _dragIndex,
                        builder: (context, dragIndex, _) => Row(
                          children: [
                            for (var index = 0;
                                index < widget.items.length;
                                index++)
                              Expanded(
                                child: _DockItem(
                                  item: widget.items[index],
                                  isActive: index ==
                                      (dragIndex ?? widget.currentIndex),
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
                      ),
                    ],
                  ),
                ),
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
    final fallbackIcon = isActive ? (item.activeIcon ?? item.icon) : item.icon;
    final icon = isActive
        ? (item.activeAndroidIcon ?? item.androidIcon)
        : item.androidIcon;
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
                child: IconTheme(
                  data: IconThemeData(color: color, size: 25),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: color),
                    child: icon ?? Icon(fallbackIcon),
                  ),
                ),
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
  /// Describes one destination in a [LiquidGlassNavBar].
  ///
  /// [icon] and [label] provide cross-platform fallbacks. Android can replace
  /// the icon with arbitrary widgets through [androidIcon] and
  /// [activeAndroidIcon]. iOS can use explicit SF Symbol names through
  /// [iosSystemImage] and [iosSelectedSystemImage].
  const LiquidGlassNavItem({
    required this.icon,
    this.activeIcon,
    this.androidIcon,
    this.activeAndroidIcon,
    required this.label,
    this.badge,
    this.iosSystemImage,
    this.iosSelectedSystemImage,
  });

  /// Material icon used by the Flutter fallback and for automatic SF Symbol
  /// mapping when no platform-specific icon is supplied.
  final IconData icon;

  /// Optional icon shown when this item is selected.
  final IconData? activeIcon;

  /// Optional widget rendered by the Flutter fallback nav bar on Android and
  /// other non-iOS platforms.
  ///
  /// If omitted, [icon] is rendered as a normal [Icon]. The widget inherits an
  /// [IconTheme] and [DefaultTextStyle] with the current active/inactive color.
  final Widget? androidIcon;

  /// Optional widget rendered by the Flutter fallback nav bar when selected.
  ///
  /// If omitted, [androidIcon] is reused. If both widget fields are omitted,
  /// [activeIcon] falls back to [icon].
  final Widget? activeAndroidIcon;

  /// Text displayed below the icon when the bar shows labels.
  final String label;

  /// Optional badge count.
  ///
  /// The badge is hidden when null, zero, or negative.
  final int? badge;

  /// Optional SF Symbol name used by the native iOS tab bar.
  ///
  /// If omitted, the plugin maps common Material icons to SF Symbols.
  final String? iosSystemImage;

  /// Optional selected-state SF Symbol name used by the native iOS tab bar.
  ///
  /// When omitted, [iosSystemImage] or the automatic Material-icon mapping is
  /// reused.
  final String? iosSelectedSystemImage;
}

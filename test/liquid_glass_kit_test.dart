import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liquid_glass_kit/flutter_liquid_glass_kit.dart';
import 'package:flutter_liquid_glass_kit/src/fallback_glass.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('routes only iOS to the native surface', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(isNativeLiquidGlassSupported, isFalse);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(isNativeLiquidGlassSupported, isTrue);
  });

  test('settings preserve a supplied Android glass colour', () {
    const colour = Color(0xFF6750A4);
    const settings = LiquidGlassSettings(tintColor: colour, tintOpacity: 0.3);

    final updated = settings.copyWith(blurSigma: 28);

    expect(updated.tintColor, colour);
    expect(updated.tintOpacity, 0.3);
    expect(updated.blurSigma, 28);
  });

  testWidgets('glass scroll behavior removes overscroll indicators', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Placeholder(),
      ),
    );

    final context = tester.element(find.byType(Placeholder));
    const child = SizedBox(width: 80, height: 40);
    const behavior = LiquidGlassScrollBehavior();
    final details = ScrollableDetails(
      direction: AxisDirection.down,
      controller: ScrollController(),
    );

    expect(
      behavior.buildOverscrollIndicator(context, child, details),
      same(child),
    );

    details.controller?.dispose();
  });

  testWidgets('uses the Flutter fallback on Android', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlatformGlass(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          child: SizedBox(width: 80, height: 40),
        ),
      ),
    );

    expect(find.byType(FallbackGlass), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Android nav bar can render a custom widget icon', (
    tester,
  ) async {
    const items = [
      LiquidGlassNavItem(
        icon: Icons.home,
        label: 'Home',
        androidIcon: Text('H'),
      ),
      LiquidGlassNavItem(
        icon: Icons.search,
        label: 'Search',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              LiquidGlassNavBar(
                currentIndex: 0,
                onTap: _noop,
                items: items,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('H'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Android nav indicator grows beyond the bar during a jump', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(
              children: [
                LiquidGlassNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: _navItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Saved'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 275));

    final indicator = tester.getRect(
      find.byKey(const ValueKey('liquid-glass-nav-indicator')),
    );
    expect(indicator.height, greaterThan(64));
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Android nav indicator follows a held horizontal drag', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(
              children: [
                LiquidGlassNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: _navItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final navRect = tester.getRect(find.byType(LiquidGlassNavBar));
    final itemWidth = navRect.width / _navItems.length;
    final gesture = await tester.startGesture(
      Offset(navRect.left + itemWidth / 2, navRect.center.dy),
    );
    await gesture.moveTo(
      Offset(navRect.right - itemWidth / 2, navRect.center.dy),
    );
    await tester.pump();

    final indicator = tester.getRect(
      find.byKey(const ValueKey('liquid-glass-nav-indicator')),
    );
    expect(indicator.center.dx, closeTo(navRect.right - itemWidth / 2, 1));

    final savedLabel = tester.widget<AnimatedDefaultTextStyle>(
      _animatedLabel('Saved'),
    );
    expect(savedLabel.style.color, Colors.white);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(selectedIndex, 0);

    await gesture.up();
    await tester.pump();
    expect(selectedIndex, 2);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('holding the Android nav indicator expands it', (tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(
              children: [
                LiquidGlassNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: _navItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final indicatorFinder =
        find.byKey(const ValueKey('liquid-glass-nav-indicator'));
    final restingRect = tester.getRect(indicatorFinder);
    final gesture = await tester.startGesture(restingRect.center);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 180));

    final heldRect = tester.getRect(indicatorFinder);
    expect(heldRect.width, greaterThan(restingRect.width));
    expect(heldRect.height, greaterThan(restingRect.height));
    expect(selectedIndex, 0);

    await gesture.up();
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('cancelling an Android nav drag restores the current item', (
    tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Stack(
              children: [
                LiquidGlassNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: _navItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final navRect = tester.getRect(find.byType(LiquidGlassNavBar));
    final itemWidth = navRect.width / _navItems.length;
    final gesture = await tester.startGesture(
      Offset(navRect.left + itemWidth / 2, navRect.center.dy),
    );
    await gesture.moveTo(
      Offset(navRect.right - itemWidth / 2, navRect.center.dy),
    );
    await tester.pump();
    await gesture.cancel();
    await tester.pump();

    final homeLabel = tester.widget<AnimatedDefaultTextStyle>(
      _animatedLabel('Home'),
    );
    expect(homeLabel.style.color, Colors.white);
    expect(selectedIndex, 0);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

void _noop(int index) {}

const _navItems = [
  LiquidGlassNavItem(icon: Icons.home, label: 'Home'),
  LiquidGlassNavItem(icon: Icons.search, label: 'Search'),
  LiquidGlassNavItem(
    icon: Icons.favorite_border,
    activeIcon: Icons.favorite,
    label: 'Saved',
  ),
];

Finder _animatedLabel(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is AnimatedDefaultTextStyle &&
        widget.child is Text &&
        (widget.child as Text).data == label,
  );
}

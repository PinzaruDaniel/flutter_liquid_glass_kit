import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_kit/liquid_glass_kit.dart';
import 'package:liquid_glass_kit/src/fallback_glass.dart';

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
}

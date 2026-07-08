// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:example/app.dart';

void main() {
  testWidgets('renders the Liquid Glass showcase', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Liquid Glass Kit'), findsOneWidget);
    expect(find.text('Glass Card'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Glass'), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved Surfaces'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('handles fast navigation taps without switcher key errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final label in ['Search', 'Saved', 'Profile', 'Home', 'Saved']) {
      await tester.tap(find.text(label).last);
      await tester.pump(const Duration(milliseconds: 40));
    }

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Saved Surfaces'), findsOneWidget);
  });

  testWidgets('jumping over a page keeps the target nav item selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Saved'));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('Explore Glass'), findsNothing);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Saved Surfaces'), findsOneWidget);
  });
}

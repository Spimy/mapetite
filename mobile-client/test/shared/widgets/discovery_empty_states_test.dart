import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/shared/widgets/empty_feed_state.dart';
import 'package:mapetite/shared/widgets/location_denied_state.dart';
import 'package:mapetite/shared/widgets/network_error_state.dart';

void main() {
  group('NetworkErrorState', () {
    testWidgets('renders wifi-off icon, copy, and an outlined Retry CTA',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: NetworkErrorState(onRetry: () => tapped = true)),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Could not connect.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });
  });

  group('EmptyFeedState', () {
    testWidgets('renders map-pin icon, copy, and a default "Try Again" CTA',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: EmptyFeedState(onCta: () => tapped = true)),
      ));

      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.text('Nothing nearby.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(tapped, isTrue);
    });

    testWidgets('renders a custom CTA label when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyFeedState(ctaLabel: 'Expand Radius', onCta: () {}),
        ),
      ));

      expect(find.text('Expand Radius'), findsOneWidget);
      expect(find.text('Try Again'), findsNothing);
    });
  });

  group('LocationDeniedState', () {
    testWidgets('renders location icon, copy, and an Open Settings CTA',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LocationDeniedState()),
      ));

      expect(find.byIcon(Icons.location_disabled), findsOneWidget);
      expect(find.text('Location needed.'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}

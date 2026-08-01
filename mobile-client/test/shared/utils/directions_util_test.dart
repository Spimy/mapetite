import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/utils/directions_util.dart';

class _MockUrlLauncherPlatform extends UrlLauncherPlatform {
  _MockUrlLauncherPlatform(this._result);
  bool _result;
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return _result;
  }
}

const _store = StoreModel(
  id: '23',
  businessName: 'Jaya Grocer @ Sunway Pyramid',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Sunway Pyramid, Selangor',
  latitude: 3.0733,
  longitude: 101.6067,
);

void main() {
  testWidgets('launches a Google Maps URL built from the store\'s coordinates', (tester) async {
    final mock = _MockUrlLauncherPlatform(true);
    UrlLauncherPlatform.instance = mock;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => openDirections(context, _store),
            child: const Text('Go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(mock.lastLaunchedUrl, contains('3.0733'));
    expect(mock.lastLaunchedUrl, contains('101.6067'));
    expect(mock.lastLaunchedUrl, contains('google.com/maps'));
  });

  testWidgets('shows an error snackbar if the launch fails', (tester) async {
    UrlLauncherPlatform.instance = _MockUrlLauncherPlatform(false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => openDirections(context, _store),
            child: const Text('Go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Unable to open'), findsOneWidget);
  });
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapetite/features/recipes/models/recipe_model.dart';
import 'package:mapetite/features/recipes/providers/recipe_provider.dart';
import 'package:mapetite/features/recipes/screens/recipe_detail_screen.dart';
import 'package:mapetite/features/recipes/services/recipe_service.dart';

// RecipeDetailScreen has no dedicated "detail" provider: it reads
// recipeByIdProvider (derived from recipeListProvider's state) and, on
// first build, triggers recipeListProvider.notifier.loadRecipeById(id) via
// RecipeService. So the test fakes RecipeService (via recipeServiceProvider)
// rather than overriding a nonexistent recipeDetailProvider.
class _FakeRecipeService extends RecipeService {
  _FakeRecipeService(this._recipe);

  final RecipeModel _recipe;

  @override
  Future<RecipeModel> getRecipeById(String id, {int? currentUserId}) async {
    return _recipe;
  }
}

// A 1x1 transparent PNG, used so Image.network resolves successfully in the
// widget test instead of hitting the real network.
final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
]);

class _FakeHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(<List<int>>[_kTransparentImage])
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final RecipeModel _recipeWithThumbnail = RecipeModel(
  id: 'r1',
  title: 'Nasi Lemak',
  authorName: 'Alice',
  authorInitial: 'A',
  cookMinutes: 20,
  calories: 500,
  servings: 2,
  ingredients: const [],
  steps: const [],
  thumbnailUrl: 'https://example.com/thumb.png',
  createdAt: DateTime(2026, 1, 1),
);

final RecipeModel _recipeWithoutThumbnail = RecipeModel(
  id: 'r1',
  title: 'Nasi Lemak',
  authorName: 'Alice',
  authorInitial: 'A',
  cookMinutes: 20,
  calories: 500,
  servings: 2,
  ingredients: const [],
  steps: const [],
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  testWidgets('renders the real thumbnail image when thumbnailUrl is set',
      (tester) async {
    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          recipeServiceProvider
              .overrideWithValue(_FakeRecipeService(_recipeWithThumbnail)),
        ],
        child: const MaterialApp(home: RecipeDetailScreen(recipeId: 'r1')),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsWidgets);
      expect(find.byIcon(Icons.restaurant_menu), findsNothing);
    }, createHttpClient: (context) => _FakeHttpClient());
  });

  testWidgets('falls back to the placeholder icon when thumbnailUrl is null',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        recipeServiceProvider
            .overrideWithValue(_FakeRecipeService(_recipeWithoutThumbnail)),
      ],
      child: const MaterialApp(home: RecipeDetailScreen(recipeId: 'r1')),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}

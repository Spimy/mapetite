import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeFeedProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(milliseconds: 1500));
});

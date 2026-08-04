import 'package:flutter/widgets.dart';

/// Non-web platforms don't use a rendered button; they get an idToken
/// directly from the native sign-in sheet instead.
Widget buildGoogleSignInWebButton() => const SizedBox.shrink();

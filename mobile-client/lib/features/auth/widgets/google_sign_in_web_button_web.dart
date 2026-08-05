import 'package:flutter/widgets.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

/// google_sign_in's imperative `signIn()` can't return an idToken on web
/// (the plugin only synthesizes profile data via the People API in that
/// path). Rendering Google's own button instead drives the proper OIDC
/// credential flow, which does populate idToken via `onCurrentUserChanged`.
Widget buildGoogleSignInWebButton() {
  final GoogleSignInPlatform plugin = GoogleSignInPlatform.instance;
  if (plugin is! GoogleSignInPlugin) return const SizedBox.shrink();

  return plugin.renderButton(
    configuration: GSIButtonConfiguration(
      type: GSIButtonType.standard,
      theme: GSIButtonTheme.outline,
      size: GSIButtonSize.large,
      shape: GSIButtonShape.pill,
      text: GSIButtonText.continueWith,
    ),
  );
}

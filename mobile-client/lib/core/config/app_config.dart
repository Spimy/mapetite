abstract class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8000/api/',
  );

  /// The Web OAuth client is per-developer: each teammate registers their own
  /// in their local Django admin (see server/README.md), so this must be
  /// overridable rather than hardcoded for everyone.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '823401679057-apgal0kbg12j629mpjo49dncnvea3bi4.apps.googleusercontent.com',
  );

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableLogging = !isProduction;

  /// Django's ImageField serializes to a root-relative path (e.g.
  /// `/media/users/avatars/x.jpg`) rather than an absolute URL, so it needs
  /// the API's origin prepended before an `Image`/`CachedNetworkImage`
  /// widget can actually load it.
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final origin = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$origin$url';
  }
}

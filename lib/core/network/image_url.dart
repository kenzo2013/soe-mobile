import '../env/env.dart';

/// Resolves a possibly relative image URL into an absolute one.
///
/// The backend returns some images (avatars, ActiveStorage blobs) as a path relative to the
/// host root, e.g. `/rails/active_storage/blobs/redirect/.../photo.jpg`. `NetworkImage` needs
/// an absolute URL, so the API origin (`scheme://host`) is prefixed. Without a configured API
/// (tests, before bootstrap) a relative path cannot be resolved: null, never a crash.
abstract final class ImageUrl {
  static String? resolve(String? url, {String? origin}) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) return url; // already absolute
    final base = origin ?? Env.apiOrigin;
    if (base == null) return null;
    return '$base${url.startsWith('/') ? '' : '/'}$url';
  }
}

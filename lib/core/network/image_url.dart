import '../env/env.dart';

/// Resout une URL d'image potentiellement relative en URL absolue.
///
/// Le backend renvoie certaines images (avatars, blobs ActiveStorage) sous
/// forme de chemin relatif a la racine du host, ex :
/// `/rails/active_storage/blobs/redirect/.../photo.jpg`.
/// `NetworkImage` exige une URL absolue → on prefixe avec l'origin de l'API
/// (`scheme://host`, sans le suffixe `/api/v1` du baseUrl).
abstract final class ImageUrl {
  static String? resolve(String? url) {
    if (url == null || url.isEmpty) return null;
    final u = Uri.tryParse(url);
    if (u != null && u.hasScheme) return url; // deja absolu
    final origin = Uri.parse(Env.apiBaseUrl).origin; // https://host
    return '$origin${url.startsWith('/') ? '' : '/'}$url';
  }
}

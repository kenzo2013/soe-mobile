/// One page of an API v2 list: `{ "data": [ … ], "meta": { page, per_page, total_count, total_pages } }`.
///
/// Named `Paginated` (not `Page`): `Page` already exists in Flutter and go_router.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.perPage,
    required this.totalCount,
    required this.totalPages,
  });

  /// Builds a page from the v2 envelope, mapping each item with [fromJson].
  factory Paginated.fromEnvelope(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = (body['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    return Paginated(
      items: data.map(fromJson).toList(growable: false),
      page: (meta['page'] as num?)?.toInt() ?? 1,
      perPage: (meta['per_page'] as num?)?.toInt() ?? data.length,
      totalCount: (meta['total_count'] as num?)?.toInt() ?? data.length,
      totalPages: (meta['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  final List<T> items;
  final int page;
  final int perPage;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;

  /// Same page with the items converted (DTO -> entity in the repository).
  Paginated<R> map<R>(R Function(T) convert) => Paginated(
        items: items.map(convert).toList(growable: false),
        page: page,
        perPage: perPage,
        totalCount: totalCount,
        totalPages: totalPages,
      );
}

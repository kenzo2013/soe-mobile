import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/network/paginated.dart';

void main() {
  test('builds a page from the v2 envelope', () {
    final page = Paginated.fromEnvelope(
      {
        'data': [
          {'id': 1},
          {'id': 2},
        ],
        'meta': {'page': 1, 'per_page': 2, 'total_count': 5, 'total_pages': 3},
      },
      (json) => json['id'] as int,
    );

    expect(page.items, [1, 2]);
    expect(page.totalCount, 5);
    expect(page.hasMore, isTrue);
    expect(page.map((id) => 'n$id').items, ['n1', 'n2']);
  });

  test('tolerates a missing meta (last page)', () {
    final page = Paginated.fromEnvelope({'data': <dynamic>[]}, (json) => json);

    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
    expect(page.perPage, Paginated.defaultPerPage);
  });
}

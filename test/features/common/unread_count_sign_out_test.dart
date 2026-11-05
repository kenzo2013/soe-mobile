import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/features/common/presentation/providers.dart';

import '../../helpers/fake_api.dart';

void main() {
  test('signed out, the bell count asks nothing of the API', () async {
    final api = FakeApi();
    final container = ProviderContainer(overrides: [
      dioV2Provider.overrideWithValue(api.dio),
      authTokenProvider.overrideWith((ref) => 'jwt'),
      currentRoleProvider.overrideWith((ref) => 'parent'),
    ]);
    addTearDown(container.dispose);
    final subscription =
        container.listen(unreadNotificationsProvider, (_, __) {});
    addTearDown(subscription.close);

    await container.read(unreadNotificationsProvider.future);
    expect(api.sent('GET /notifications/unread_count'), hasLength(1));

    // Sign-out: the token goes first, the bell is still listening.
    container.read(authTokenProvider.notifier).state = null;
    container.read(currentRoleProvider.notifier).state = null;
    expect(await container.read(unreadNotificationsProvider.future), 0);
    expect(api.sent('GET /notifications/unread_count'), hasLength(1));
  });
}

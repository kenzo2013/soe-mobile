import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/routing/route_guards.dart';
import 'package:soe/core/routing/route_names.dart';

/// A session refused by the API (401) clears the token: the guard sends the open screen of a
/// space back to the sign-in at once (AUT-11), instead of an error inside the tabs.
void main() {
  testWidgets('a space screen goes back to the sign-in when the session ends',
      (tester) async {
    final container = ProviderContainer(overrides: [
      authTokenProvider.overrideWith((ref) => 'token'),
      currentRoleProvider.overrideWith((ref) => 'parent'),
    ]);
    addTearDown(container.dispose);
    final guard = AuthGuard(
      isAuthenticated: () => container.read(authTokenProvider) != null,
      currentRole: () => container.read(currentRoleProvider),
      onboardingDone: () => true,
    );
    final sessionEnded = ValueNotifier<int>(0);
    addTearDown(sessionEnded.dispose);
    container.listen(authTokenProvider, (previous, next) {
      if (previous != null && next == null) sessionEnded.value++;
    });
    final router = GoRouter(
      initialLocation: RouteNames.parentPayments,
      redirect: guard.redirect,
      refreshListenable: sessionEnded,
      routes: [
        GoRoute(
            path: RouteNames.parentPayments,
            builder: (_, __) => const Text('payments')),
        GoRoute(
            path: RouteNames.login, builder: (_, __) => const Text('sign-in')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('payments'), findsOneWidget);

    container.read(sessionExpiredProvider.notifier).state = true;
    container.read(authTokenProvider.notifier).state = null;
    await tester.pumpAndSettle();
    expect(find.text('sign-in'), findsOneWidget);
  });

  test('without a session, only the public screens stay open', () {
    final guard = AuthGuard(
      isAuthenticated: () => false,
      currentRole: () => null,
      onboardingDone: () => true,
    );
    String? redirect(String location) => guard.redirect(
        _FakeContext(),
        GoRouterState(
          _FakeConfiguration(),
          uri: Uri.parse(location),
          matchedLocation: location,
          fullPath: location,
          pathParameters: const {},
          pageKey: const ValueKey('page'),
        ));
    expect(redirect(RouteNames.parentPayments), RouteNames.login);
    expect(redirect(RouteNames.tutorHome), RouteNames.login);
    expect(redirect(RouteNames.login), isNull);
    expect(redirect(RouteNames.passwordForgot), isNull);
  });
}

class _FakeContext extends Fake implements BuildContext {}

class _FakeConfiguration extends Fake implements RouteConfiguration {}

---
name: soe-route
description: Ajoute une sous-route go_router à une feature SOE — JAMAIS dans le router racine. À utiliser à chaque nouvelle page exposée à la navigation.
---

# soe-route

Le router est **modulaire**. Chaque feature gère ses propres routes dans `lib/features/<feature>/presentation/routes.dart`. Le router racine (`lib/core/routing/app_router.dart`) ne fait qu'agréger.

## Règle dure
**Interdit d'ajouter une route directement dans `app_router.dart`.** Toujours passer par `<feature>/presentation/routes.dart`.

## Template `routes.dart` de feature

```dart
// lib/features/<feature>/presentation/routes.dart
import 'package:go_router/go_router.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/features/<feature>/presentation/pages/<page>_page.dart';

List<RouteBase> <feature>Routes() => [
  GoRoute(
    path: RouteNames.<feature>List,
    name: RouteNames.<feature>List,
    builder: (context, state) => const <Page>Page(),
    routes: [
      GoRoute(
        path: ':id',
        name: RouteNames.<feature>Detail,
        builder: (context, state) => <Page>DetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  ),
];
```

## Ajouter le nom de route
```dart
// lib/core/routing/route_names.dart
abstract final class RouteNames {
  static const String <feature>List = '/<feature>';
  static const String <feature>Detail = '<feature>-detail';
}
```

## Brancher dans le router racine
```dart
// lib/core/routing/app_router.dart
GoRouter buildRouter(...) => GoRouter(
  routes: [
    ...authRoutes(),
    ...<feature>Routes(),   // <-- une seule ligne par feature
  ],
  redirect: AuthGuard(...).redirect,
);
```

## Auth / role guards
- **Pas de logique d'auth dans la page** : route guard déclaratif dans `core/routing/route_guards.dart`.
- Routes publiques (login, register, password reset) listées explicitement.
- Routes par rôle (parent / tutor) : guard qui lit le state d'auth + role courant.

## Anti-patterns
- ❌ Une route inscrite à deux endroits.
- ❌ `Navigator.push(MaterialPageRoute(...))` directement (ignore go_router).
- ❌ Path en dur dans une page (`context.go('/parent/students')`) : utiliser `RouteNames.studentsList`.
- ❌ Logique métier dans `redirect:` : déléguer au `route_guards.dart`.

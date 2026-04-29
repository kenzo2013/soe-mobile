---
name: soe-page
description: Crée une Page MVVM SOE (ConsumerWidget, state.when, sans BuildContext dans VM, sans try/catch). À utiliser pour chaque écran utilisateur.
---

# soe-page

Génère un `*_page.dart` propre selon les règles MVVM strictes.

## Template

```dart
// lib/features/<feature>/presentation/pages/<name>_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soe/core/widgets/error_view.dart';
import 'package:soe/features/<feature>/presentation/viewmodels/<name>_viewmodel.dart';

class <Name>Page extends ConsumerWidget {
  const <Name>Page({super.key /*, named params */});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(<name>ViewModelProvider);

    // Side-effects via ref.listen — JAMAIS dans le build pur
    ref.listen(<name>ViewModelProvider, (prev, next) {
      next.maybeWhen(
        error: (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.userMessage(context))),
        ),
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('<Title>')),
      body: switch (state) {
        _Initial() => const SizedBox.shrink(),
        _Loading() => const <Name>Skeleton(),
        _Loaded(:final data) => <Name>Content(data: data),
        _Error(:final failure) => ErrorView(
            failure: failure,
            onRetry: () => ref.read(<name>ViewModelProvider.notifier).load(),
          ),
      },
    );
  }
}
```

## Règles dures (vérifiées en review)
1. **`StatelessWidget` ou `ConsumerWidget`** uniquement (pas de `StatefulWidget` sauf widgets purement locaux : animations, focus).
2. **Aucun appel HTTP / Dio** dans une page.
3. **Aucun `setState`** sauf widget local sans logique métier.
4. **Aucun `try/catch`** : la page lit le state.
5. **Aucun `print`** : `logger.d(...)` si besoin de debug.
6. **`switch` exhaustif sur sealed state** (Dart 3 patterns) — pas de `state.map` qui peut oublier un cas.
7. **Fichier ≤ 300 lignes**, méthode `build` ≤ 50 lignes — au-delà, extraire des sous-widgets dans `presentation/widgets/`.
8. **Pas de magic strings** : labels via `slang` (`t.feature.x`), couleurs via `AppPalette`.
9. **Pas de tailles en dur en pixel** : `flutter_screenutil` (`12.w`, `16.sp`) si présent.

## États à toujours gérer
- `initial` : retour silencieux (`SizedBox.shrink`).
- `loading` : skeleton ou `CircularProgressIndicator` adapté.
- `loaded` : contenu principal.
- `error` : `ErrorView` avec retry.

Si un état manque dans le sealed, **ne pas masquer avec `_ => ...`** — étendre le state.

## Test widget minimum
```dart
testWidgets('shows skeleton when loading', (tester) async {
  await pumpAppWith(
    tester,
    overrides: [<name>ViewModelProvider.overrideWith(() => _Loading())],
    child: const <Name>Page(),
  );
  expect(find.byType(<Name>Skeleton), findsOneWidget);
});
```

Couvrir au minimum : skeleton (loading), contenu (loaded), erreur avec retry (error).

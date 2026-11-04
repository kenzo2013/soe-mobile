---
name: soe-page
description: Crée une page SOE (ConsumerWidget, widgets Soe*, textes slang, états chargement/vide/erreur, effets via ref.listen et SoeToast). À utiliser pour chaque écran utilisateur.
---

# soe-page

Avant d'écrire : ouvrir l'écran dans le Studio (identifiant AUT-, PAR-, REP-, COM-) au format
mobile 390 **et** tablette 834, avec tous ses états.

## Template — données chargées (`AsyncNotifier`)

```dart
// lib/features/<feature>/presentation/pages/quotes_page.dart
class QuotesPage extends ConsumerWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final quotes = ref.watch(quotesViewModelProvider);

    return Scaffold(
      appBar: SoeAppBar(title: tr.quotes.title),
      body: quotes.when(
        loading: () => const QuotesSkeleton(),
        error: (error, _) => ErrorView(
          failure: asFailure(error), // never `as Failure`: a parsing error is not a Failure
          onRetry: () => ref.invalidate(quotesViewModelProvider),
        ),
        data: (items) => items.isEmpty
            ? SoeEmptyState(title: tr.quotes.empty.title, message: tr.quotes.empty.message)
            : RefreshIndicator(
                onRefresh: ref.read(quotesViewModelProvider.notifier).refresh,
                child: QuotesList(items: items),
              ),
      ),
    );
  }
}
```

## Template — action (`Notifier`)

```dart
ref.listen(acceptQuoteViewModelProvider, (previous, next) {
  switch (next) {
    case AcceptQuoteSuccess():
      SoeToast.show(context, message: tr.quotes.accepted, tone: SoeToastTone.success);
      context.go(RouteNames.parentContract);
    case AcceptQuoteError(:final failure):
      SoeToast.show(context, message: failureMessage(failure, tr), tone: SoeToastTone.danger);
    case AcceptQuoteInitial() || AcceptQuoteLoading():
      break;
  }
});

final accepting = ref.watch(acceptQuoteViewModelProvider) is AcceptQuoteLoading;
SoeButton(
  label: tr.quotes.accept,
  loading: accepting,
  onPressed: accepting ? null : () => ref.read(acceptQuoteViewModelProvider.notifier).accept(id),
);
```

`failureMessage` traduit une `Failure` en texte : c'est la correspondance qui vit aujourd'hui
dans `ErrorView`, à extraire dans `lib/core/error/failure_message.dart` à sa première utilisation
(une seule correspondance pour toute l'app).

## Règles dures
1. `ConsumerWidget` / `StatelessWidget`. `StatefulWidget` seulement pour un état purement local
   (contrôleur de texte, animation, focus).
2. **Widgets `Soe*` et tokens `App*` uniquement** (skill `soe-design-system`) :
   pas de `TextStyle(fontSize:)`, `Color(0x…)`, `EdgeInsets.all(13)`, bouton ou champ Material brut.
3. **Retours utilisateur par `SoeToast.show`**, jamais `ScaffoldMessenger…showSnackBar`.
   Confirmation par `SoeConfirmDialog.show`, jamais `showDialog` brut.
4. **Aucun texte en dur** : `Translations.of(context)` (skill `soe-i18n`), y compris
   `semanticsLabel` et `tooltip`.
5. Aucun appel HTTP, aucun `try/catch`, aucun `print` dans une page.
6. `switch` exhaustif sur un state sealed ; pas de `_ =>` qui masque un état oublié.
7. Fichier ≤ 300 lignes, `build` ≤ 50 lignes : extraire dans `presentation/widgets/`.
8. Navigation par `RouteNames` (skill `soe-route`), jamais un chemin en dur.
9. Mise en page tablette (≥ 600 px de large) : `LayoutBuilder`, contenu centré et limité en
   largeur ou deux colonnes selon le Studio ; jamais une page mobile étirée.
10. Accessibilité : cibles ≥ 44 px, `Semantics` sur les icônes seules (skill `soe-a11y-audit`).

## États à toujours prévoir
Chargement (squelette `SoeSkeleton`), vide (`SoeEmptyState` avec action), erreur
(`ErrorView` avec réessayer), contenu, et les variantes métier montrées dans le Studio.

## Tests
Skill `soe-widget-test-golden` : un test par état, un golden 390 et 834 pour l'état principal.

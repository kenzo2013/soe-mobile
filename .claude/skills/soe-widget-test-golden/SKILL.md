---
name: soe-widget-test-golden
description: Écrire les tests de widget et les goldens d'un écran ou d'un widget SOE (états chargement/vide/erreur/contenu, formats 390 et 834, texte agrandi) avec pumpAppWith, mocktail et golden_toolkit.
---

# Tests de widget et goldens

Outils : `flutter_test`, `mocktail`, `golden_toolkit`, helpers `test/helpers/pump_app.dart`
(`pumpAppWith`) et `test/helpers/test_di.dart` (`makeContainer`). Noms de tests en anglais.

## Test de widget d'un écran

```dart
void main() {
  testWidgets('shows the empty state when there is no quote', (tester) async {
    await pumpAppWith(
      tester,
      overrides: [quotesViewModelProvider.overrideWith(() => _FakeQuotes(const []))],
      child: const QuotesPage(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SoeEmptyState), findsOneWidget);
  });
}

class _FakeQuotes extends QuotesViewModel {
  _FakeQuotes(this._items);
  final List<Quote> _items;

  @override
  Future<List<Quote>> build() async => _items;
}
```

Un test par état : chargement (squelette), vide, erreur (+ « Réessayer » rappelle le view
model), contenu, et chaque variante métier ; un test par action (le bon appel est fait,
le toast ou la navigation suit).

`pumpAppWith` doit fournir la locale et les traductions (`TranslationProvider`) : s'il ne le
fait pas encore, l'ajouter au helper plutôt que dans chaque test.

## Goldens

```dart
testGoldens('quotes page', (tester) async {
  await loadAppFonts();
  final builder = DeviceBuilder()
    ..overrideDevicesForAllScenarios(devices: const [
      Device(name: 'phone', size: Size(390, 844)),
      Device(name: 'tablet', size: Size(834, 1194)),
      Device(name: 'phone_large_text', size: Size(390, 844), textScale: 1.3),
    ])
    ..addScenario(widget: _page(withQuotes), name: 'content')
    ..addScenario(widget: _page(empty), name: 'empty');
  await tester.pumpDeviceBuilder(builder, wrapper: soeGoldenWrapper());
  await screenMatchesGolden(tester, 'quotes_page');
});
```

- Fichiers dans `test/**/goldens/`, générés **sur la même machine que la CI** (les rendus de
  polices diffèrent entre macOS et Linux) ; en local, ne régénérer qu'en connaissance de cause.
- `flutter test --update-goldens` seulement quand le changement visuel est voulu, et montrer
  l'avant / après dans la pull request.
- Données de test fixes (noms, montants, dates figées) : jamais `DateTime.now()`.
- Comparer le golden au Studio avant de le valider : un golden faux fige une erreur.

## Couverture attendue
Use cases et mappers 100 %, view models ≥ 90 %, un test de widget par page, un golden par page
principale et par widget `Soe*`.

---
name: soe-a11y-audit
description: Auditer l'accessibilité d'un écran ou d'un widget SOE (lecteur d'écran, contrastes, cibles tactiles, texte agrandi, focus, langue) et corriger. À utiliser sur chaque écran créé ou refait.
---

# Audit d'accessibilité

Les utilisateurs de SOE ont des téléphones d'entrée de gamme, parfois de grandes tailles de
texte, et des parents peu à l'aise avec le numérique : l'accessibilité est un critère de
« terminé ».

## Grille

| Point | Exigence | Comment vérifier |
|---|---|---|
| Libellés | Toute icône seule, image porteuse de sens, bouton sans texte a un `Semantics` / `semanticsLabel` traduit | Test : `find.bySemanticsLabel(...)` ; TalkBack / VoiceOver sur simulateur |
| Rôles | Boutons annoncés comme boutons, en-têtes comme en-têtes (`Semantics(header: true)`) | `tester.getSemantics(...)` |
| Cibles | ≥ 44 × 44 (`meetsGuideline(androidTapTargetGuideline)` / `iOSTapTargetGuideline`) | test de widget |
| Contrastes | Texte ≥ 4,5:1, gros texte et icônes ≥ 3:1 (`meetsGuideline(textContrastGuideline)`) | test de widget |
| Texte agrandi | Écran utilisable à `textScaler` 1,3 sans débordement ni texte coupé | golden `phone_large_text` |
| Ordre | Ordre de lecture = ordre visuel ; erreurs de formulaire annoncées | lecteur d'écran |
| États | Désactivé expliqué (« Il manque : … »), chargement annoncé, succès / erreur lisibles sans couleur | revue |
| Mouvement | Pas d'animation indispensable ; respecter `MediaQuery.disableAnimations` | revue |
| Langue | Textes dans la langue choisie, montants et dates lus correctement | revue |

## Test type

```dart
testWidgets('quotes page meets accessibility guidelines', (tester) async {
  final handle = tester.ensureSemantics();
  await pumpAppWith(tester, child: const QuotesPage(), overrides: [...]);
  await tester.pumpAndSettle();

  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
});
```

## Rendu
Tableau (point, résultat ✅ / ❌, correction) ; corrections faites dans le widget `Soe*`
concerné quand le défaut vient du design system, pour que tous les écrans en profitent.

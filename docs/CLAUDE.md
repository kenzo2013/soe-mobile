# SOE mobile — règles du dépôt (source unique)

Application Flutter de SOE (soutien scolaire à domicile, Douala et Yaoundé) pour les **parents**
et les **répétiteurs**. Le back-office n'existe pas sur mobile. L'API vient du dépôt Rails `soe`.

---

## 🔴 Règle 0 — tout le code s'écrit en anglais

Classes, méthodes, variables, paramètres, **commentaires**, noms de fichiers, chemins de routes,
clés de traduction : **anglais**. Seuls les **textes affichés** (`lib/i18n/fr.i18n.json`,
`en.i18n.json`) sont en français et en anglais. Vocabulaire : répétiteur = `tutor`,
séance = `session`, devis = `quote`, PV = `sessionReport`, pointage = `checkIn`/`checkOut`.
Une habitude observée dans le code n'est pas une règle.

---

## Règles obligatoires

1. **UI** : uniquement les widgets `Soe*` de `lib/core/widgets/` et les tokens `AppPalette`,
   `AppTypography`, `AppSpacing`, `AppRadius` (skill `soe-design-system`). Un besoin non couvert →
   nouveau widget (skill `soe-component`), jamais un contournement local.
2. **Architecture** (ADR 0001, `REBUILD_SPEC.md`) : Domain / Data / Presentation par feature,
   `Result<S, Failure>`, aucun `BuildContext` hors des widgets, aucun `try/catch` en Presentation.
3. **État** : Riverpod `Notifier` / `AsyncNotifier` (décision v2). `StateNotifier` est
   l'ancien style : on ne l'écrit plus, on migre l'écran quand on le touche (skill `soe-viewmodel`).
4. **Textes** : `Translations.of(context)` (slang), FR et EN dans la même modification (skill `soe-i18n`).
5. **API** : v2, enveloppe `{ data, meta, errors }` (skill `soe-api-v2`). La v1 reste utilisée
   tant que l'endpoint v2 n'existe pas.
6. **Tests** : use cases, mappers, view models, et un test de widget par écran (skill
   `soe-widget-test-golden`).
7. **Avant de rendre** : skill `soe-checklist-done` (format, analyse, tests, `ds_guard`).

---

## Refonte v2 — cadre de travail

| Ressource | Lien |
|---|---|
| Studio SOE (design system, écrans mobile 390 et tablette 834, prototype D1–D10) | https://claude.ai/artifact/NhkbyFaGrUApKtX5Yv5KpS |
| Cahier des spécifications | https://claude.ai/artifact/QUh3J2RhqnDoh7WCD8ohP8 |
| Plan de réalisation par lots | https://claude.ai/artifact/F25kcH1gWVRN7JikvJ8Qeb |

**Branches** : `refonte/v2` est la branche d'intégration ; une branche `v2/<lot>-<tâche>` par
tâche, fusionnée après revue. Les tâches web et mobile d'un même lot avancent ensemble.

**Cycle d'une tâche** : Explorer (écrans du Studio par identifiant AUT-, PAR-, REP-, COM-) →
Planifier (validé par le porteur) → Coder → Tester (tests + capture sur simulateur à 390 et 834,
comparée au Studio) → checklist → pull request vers `refonte/v2`.

**Décisions actées**
- Navigation par onglets (skill `soe-tab-shell`) :
  parent = Accueil · Planning · Enfants · Paiements · Plus ;
  répétiteur actif = Aujourd'hui · Planning · Élèves · Revenus · Plus ;
  répétiteur pas encore actif = Dossier · Offres · Candidatures · Plus.
- Direction artistique v2 : surfaces plates, **pas de dégradé ni d'ombre décorative**
  (`brandGradient` et `AppShadows` sont hérités, à retirer écran par écran).
- Vocabulaire : « répétiteur » (jamais « tuteur ») ; « représentant légal ».
- Pointage par géolocalisation (≤ 150 m), code à 4 chiffres en secours.
- PV rédigé hors ligne possible (skill `soe-offline-draft`) : réseau 3G instable.
- Délais et montants viennent de l'API (paramètres du back-office), jamais en dur.
- Accessibilité : skill `soe-a11y-audit`.

---

## Stack

Flutter 3.38 (Dart ≥ 3.5), Riverpod 2.6, go_router 14, Dio 5, freezed + json_serializable,
slang (i18n), flutter_secure_storage, mocktail, golden_toolkit, patrol, very_good_analysis.
`flutter_screenutil` est une dépendance inutilisée : ne pas l'utiliser (tailles via `AppSpacing`).

## Commandes

| But | Commande |
|---|---|
| Générer (freezed, json, slang) | `dart run build_runner build --delete-conflicting-outputs` · `dart run slang` |
| Lancer en local | `flutter run --target=lib/main_dev.dart --dart-define-from-file=env/dev.env` |
| Format / analyse | `dart format --set-exit-if-changed .` · `flutter analyze` |
| Tests | `flutter test` · goldens : `flutter test --update-goldens` (seulement si le changement visuel est voulu) |
| Design system | `python3 tools/ds_guard.py --check` · fichiers de la tâche : `--diff refonte/v2` · détail : `--files <fichier>` |

## Interdits

- **Tester contre staging (`jeteste.site`) ou la production**, y créer des comptes ou des données.
  En développement, l'app pointe sur le serveur Rails **local** (tunnel), avec des comptes locaux.
- Déclencher un vrai paiement NotchPay.
- Commiter ou pousser sans demande explicite ; travailler directement sur `develop` ou `refonte/v2`.
- Secret ou clé dans `lib/` (tout passe par `env/*.env`, gitignorés).
- Augmenter un seuil de `tools/ds_guard.baseline.json`.
- Promettre à l'écran ce qui n'est pas décidé (casier, garants, rétractation, bulletin, notes).

## Outillage Claude

| Skill | Rôle |
|---|---|
| `soe-feature-scaffold` | squelette d'une feature (domain / data / presentation / tests) |
| `soe-usecase`, `soe-repository`, `soe-viewmodel`, `soe-page`, `soe-route` | une brique chacun |
| `soe-api-v2` | consommer un endpoint v2 (enveloppe, erreurs, pagination) |
| `soe-design-system` | tokens et widgets `Soe*` |
| `soe-component` | créer ou étendre un widget `Soe*` (miroir du composant web) |
| `soe-tab-shell` | navigation par onglets selon le rôle |
| `soe-i18n` | traductions FR/EN avec slang |
| `soe-offline-draft` | brouillons hors ligne (PV, formulaires longs) |
| `soe-widget-test-golden` | tests de widget et goldens |
| `soe-a11y-audit` | accessibilité d'un écran |
| `soe-ds-guard` | mesurer et réduire les écarts au design system |
| `soe-anti-patterns`, `soe-checklist-done` | relecture et définition de « terminé » |

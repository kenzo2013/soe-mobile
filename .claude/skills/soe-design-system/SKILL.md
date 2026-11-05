---
name: soe-design-system
description: Cadre l'usage des tokens et widgets partagés SOE dans toute UI. À invoquer dès qu'on touche à de l'UI, qu'on crée une page, ou qu'on rajoute un composant.
---

# soe-design-system

Source de vérité pour l'UI SOE. **Tout écran consomme ces tokens et widgets** — pas de Material brut, pas de couleurs ni de tailles littérales.

**Référence visuelle** : Studio SOE, rubriques *Fondations* et *Composants*
(https://claude.ai/artifact/NhkbyFaGrUApKtX5Yv5KpS). Chaque widget `Soe*` a son pendant web
`Soe::<Name>Component` dans le dépôt `soe` : mêmes variantes, mêmes états, mêmes tokens.

**Direction artistique v2** : surfaces plates, pas de dégradé ni d'ombre décorative. `brandGradient`,
`SoeBrandSurface` et `AppShadows` sont **hérités** : ne pas les utiliser dans un nouvel écran,
les retirer de l'écran qu'on refait. Les valeurs des tokens sont alignées sur le Studio à la tâche 0.5.

**Mesure** : `python3 tools/ds_guard.py --check` (skill `soe-ds-guard`). Aucun seuil ne doit monter.

## Tokens — `lib/core/theme/`

| Module | Usage |
|---|---|
| `AppPalette` | Échelles du Studio : `teal50…teal900`, `gold50/100/400/500/700`, `ink400/600/700/900`, `n0/n50/n100/n300`, `white` ; états `success/warning/danger/info` + `*Text` (texte AA) + `*Bg` ; `subject*` ; rôles `surfacePage/Soft/Sunken/Card/Nav`, `text/text2/text3`, `border`, `onDark/onDark2`, `overlay*`. Les noms v1 (`teal`, `yellow`, `ink2`, `brandGradient`…) restent pour les écrans v1, pas pour le nouveau code. |
| `AppTypography` | **Literata** : `display` 32, `h1` 28, `h2` 24, `h3` 20, `numberXl/L/M` · **Figtree** : `title` 18, `bodyLg` 17, `body` 16, `bodySm` 14, `label` 14/600, `labelSm` 13, `caption` 13, `overline` 12, `buttonLg` 16/700, `button` 15, `buttonSm` 14. Polices intégrées dans `assets/fonts/` (OFL). `h4`, `pageTitle`, `subtitle` = noms v1. |
| `AppSpacing` | `xs(4) / sm(8) / md(12) / lg(16) / xl(20) / xxl(24) / xxxl(32) / xxxxl(40) / huge(48) / mega(64)` |
| `AppRadius` | `xs(6) / md(14) / lg(20) / xl(28) / pill(999)` + `BorderRadius` prêts (`sm` 10 et `xxl` 24 = v1) |
| `AppShadows` | `e1`, `e2` : couches flottantes seulement (menus, feuilles, dialogues, toasts). `sm/md/lg/brand/cta` = v1 |

## Widgets — `lib/core/widgets/`

| Widget | Quand l'utiliser |
|---|---|
| `SoeButton` | Tout bouton, toujours en pilule. Variantes = matrice du Studio et noms du web : `primary` (or, un par écran), `secondary` (teal plein), `outline`, `tertiary` (texte), `danger`, `dangerOutline`, `onBrand` (contour sur teal 800). Tailles `sm 40 / md 48 / lg 52` (défaut `lg` sur mobile). Props : `icon`, `iconRight`, `loading`, `loadingLabel`, `fullWidth`. Désactivé = fond n300, texte ink600. |
| `SoeIconButton` | Icône seule 44×44, variantes filled/outline. |
| `SoeFab` | FAB jaune 56 (CTA flottant). |
| `SoeTextField` | Champ texte avec label, icône optionnelle, état erreur (halo rouge). |
| `SoePasswordField` | Mot de passe avec œil intégré. |
| `SoeSearchField` | Recherche compacte 48px sur fond n300. |
| `SoeBadge` | Badge pill, tones `success/warning/danger/info/neutral`, mode `solid`. |
| `ReservationStatus / QuoteStatus / SessionStatus / PaymentStatus.toBadge()` | Mapping direct des enums API en badge stylé. |
| `SoeCheckbox`, `SoeOtpField`, `SoePhoneField`, `SoeCountryField`, `SoePlacesAutocompleteField`, `SoeFieldLabel` | Saisies spécialisées (cases, code à 6 chiffres, téléphone +237, pays, adresse Google Places, libellé). |
| `SoeSignaturePad` + `SoeSignatureController` | Signature du contrat. |
| `SoeBrandLogo`, `SoeBackButton`, `LangPill` | Logo, retour, choix de langue. |
| `SoeCard` | Carte standard (blanche, radius 14, ombre sm, bordure n300). |
| `SoeAvatar` | 4 tailles : `mini(36) / list(52) / profile(92) / detail(116)`. Fallback initiales sur teal. |
| `SoeAlert` | Banner inline (success/warning/danger/info) avec icône cerclée + bordure gauche colorée. |
| `SoeChip` | Filtre on/off (teal plein si selected). |
| `SoeRatingStars` | 1-5 étoiles. `onChanged` → mode interactif (24px), sinon affichage (16px). |
| `SoeStatCard` | Carte statistique colorée pour dashboards (success/info/danger). |
| `SoeEmptyState` | Liste vide avec CTA optionnel. |
| `SoeFullStatusView` | Page entière statut succès/échec (gros badge + titre + body + CTA). |
| `SoeSkeleton` / `SoeSkeletonListTile` | Chargement animé shimmer. |
| `SoeAppBar` | AppBar standard (n100) ou `brand: true` (teal, texte blanc). |
| `SoeBottomNav` | Bottom nav flottante avec items actifs sur infoBg/teal. |
| `SoeConfirmDialog` | Dialog confirm (`SoeConfirmDialog.show(...)`). Mode `destructive: true` → bouton rouge. |
| `SoeToast` | Toast `SoeToast.show(context, message:, tone:)`. Remplace `ScaffoldMessenger.showSnackBar` brut. |
| `SoeSectionHeader` | En-tête (eyebrow / titre / kicker / action). |
| `SoeBrandSurface` | ⚠️ hérité (dégradé) : ne plus utiliser dans un nouvel écran. |
| `SoePageBackground` | Wrapper n100. |

## Règles dures

1. **Pas de `Color(0x...)` ni de hex littéral** dans une page : passer par `AppPalette.*`.
2. **Pas de `TextStyle(fontSize: ...)`** ad hoc : utiliser `AppTypography.*` ou `Theme.of(context).textTheme.*`.
3. **Pas de `Container(...)` + `BoxDecoration` qui réinvente une carte** : utiliser `SoeCard`.
4. **Pas de `ElevatedButton`/`TextButton`/`OutlinedButton`** Material brut : utiliser `SoeButton`.
5. **Pas de `TextField` brut** : utiliser `SoeTextField`/`SoePasswordField`/`SoeSearchField`.
6. **Pas de `ScaffoldMessenger.showSnackBar(...)`** brut : utiliser `SoeToast.show(...)`.
7. **Pas de `Padding(EdgeInsets.all(N))`** avec N hors grid 4px : utiliser `AppSpacing.*`.
8. **Bouton jaune (CTA primary) = 1 par écran maximum** — design rule.
9. **AppBar marque (`brand: true`)** réservée aux écrans top-of-flow (onboarding, splash, brand pages).
10. Sur **surface marque** (fond `surfaceNav`), n'utiliser que `primary` (or) et `onBrand` pour les boutons.
11. **Pas de `TextStyle(...)` construit dans une page** : partir d'un style `AppTypography.*` et `copyWith` si besoin.
12. **Pas de `LinearGradient` / `BoxShadow` décoratif** (v2).
13. **Pas de `showDialog` / `AlertDialog` brut** : `SoeConfirmDialog`.
14. **Pas de `flutter_screenutil`** (`.w`, `.sp`) : tailles par les tokens, adaptation par `LayoutBuilder`.

## Exemple : page type
```dart
return Scaffold(
  appBar: SoeAppBar(title: 'Mes enfants'),
  body: state.maybeWhen(
    loading: () => const Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(children: [SoeSkeletonListTile(), SoeSkeletonListTile()]),
    ),
    loaded: (items) => items.isEmpty
      ? SoeEmptyState(
          title: 'Aucun enfant',
          message: 'Ajoutez votre premier enfant pour commencer.',
          icon: Icons.school_outlined,
          actionLabel: 'Ajouter un enfant',
          onAction: () => context.push('/parent/students/new'),
        )
      : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemBuilder: (_, i) => SoeCard(child: ...),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemCount: items.length,
        ),
    error: (f) => ErrorView(failure: f, onRetry: () => ...),
    orElse: () => const SizedBox.shrink(),
  ),
  // Textes : Translations.of(context).x en vrai code (exemple simplifié).
  floatingActionButton: SoeFab(icon: Icons.add, onPressed: ...),
);
```

## Avant de créer un nouveau widget partagé
1. Cherche dans `lib/core/widgets/` — un widget proche existe peut-être déjà.
2. Si nouveau widget générique : skill `soe-component` (préfixe `Soe`, `lib/core/widgets/`, test, golden, ajout à ce tableau, pendant web).
3. Si widget propre à une feature : `lib/features/<x>/presentation/widgets/`, sans préfixe `Soe`.

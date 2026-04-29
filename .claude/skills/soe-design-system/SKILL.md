---
name: soe-design-system
description: Cadre l'usage des tokens et widgets partagés SOE dans toute UI. À invoquer dès qu'on touche à de l'UI, qu'on crée une page, ou qu'on rajoute un composant.
---

# soe-design-system

Source de vérité pour l'UI SOE. **Tout écran consomme ces tokens et widgets** — pas de Material brut, pas de couleurs ni de tailles littérales.

## Tokens — `lib/core/theme/`

| Module | Usage |
|---|---|
| `AppPalette` | Couleurs : `teal/tealDeep/tealDark`, `yellow/yellowDeep`, `ink/ink2/ink3`, `n50/n100/n300/n500/n700/n900`, `success/warning/danger/info` (+ leurs `*Bg`), `white`, `brandGradient` |
| `AppTypography` | `display/h1/h2/h3/h4/subtitle/body/bodySm/label/caption/overline/button` (Poppins) |
| `AppSpacing` | `xs(4) / sm(8) / md(12) / lg(16) / xl(20) / xxl(24) / xxxl(32) / xxxxl(40) / huge(48) / mega(64)` |
| `AppRadius` | `xs(6) / sm(10) / md(14) / lg(20) / xl(28) / pill(999)` + `rXs/rSm/rMd/rLg/rXl/rPill` (BorderRadius prêts) |
| `AppShadows` | `sm / md / lg / brand / cta` |

## Widgets — `lib/core/widgets/`

| Widget | Quand l'utiliser |
|---|---|
| `SoeButton` | Tout bouton. Variantes : `primary` (CTA jaune), `secondary` (outline teal), `tertiary` (ghost), `link`, `onBrand` / `onBrandGhost` (sur surface marque), `danger`. Tailles `sm(36) / md(48) / lg(56)`. Props : `icon`, `iconRight`, `loading`, `fullWidth`. |
| `SoeIconButton` | Icône seule 44×44, variantes filled/outline. |
| `SoeFab` | FAB jaune 56 (CTA flottant). |
| `SoeTextField` | Champ texte avec label, icône optionnelle, état erreur (halo rouge). |
| `SoePasswordField` | Mot de passe avec œil intégré. |
| `SoeSearchField` | Recherche compacte 48px sur fond n300. |
| `SoeBadge` | Badge pill, tones `success/warning/danger/info/neutral`, mode `solid`. |
| `ReservationStatus / QuoteStatus / SessionStatus / PaymentStatus.toBadge()` | Mapping direct des enums API en badge stylé. |
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
| `SoeBrandSurface` | Surface dégradée marque (top de page onboarding/auth). |
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
10. Sur **surface marque** (gradient teal), n'utiliser que `onBrand` / `onBrandGhost` pour les boutons (jamais `secondary` qui suppose fond clair).

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
  floatingActionButton: SoeFab(icon: Icons.add, onPressed: ...),
);
```

## Avant de créer un nouveau widget partagé
1. Cherche dans `lib/core/widgets/` — un widget proche existe peut-être déjà.
2. Si nouveau widget générique : préfixer `Soe`, le mettre dans `lib/core/widgets/`, l'ajouter à ce SKILL.
3. Si widget propre à une feature : `lib/features/<x>/presentation/widgets/`, sans préfixe `Soe`.

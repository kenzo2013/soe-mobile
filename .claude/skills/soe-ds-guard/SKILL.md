---
name: soe-ds-guard
description: Mesurer et réduire les écarts au design system et aux décisions v2 dans lib/ avec tools/ds_guard.py (tailles et couleurs en dur, TextStyle, Material brut, SnackBar, dégradés, StateNotifier, textes en dur), sans jamais monter un seuil.
---

# Garde du design system

`tools/ds_guard.py` compte, par règle, les occurrences qui contournent le design system ou les
décisions v2. Les seuils de `tools/ds_guard.baseline.json` ne font que **baisser**.

| Règle | Correction |
|---|---|
| `font_size`, `text_style_ctor` | `AppTypography.*` (`copyWith` pour une couleur) |
| `color_literal` | `AppPalette.*` (les couleurs de drapeaux de `countries.dart` sont exclues) |
| `raw_edge_insets` | `AppSpacing.*` |
| `raw_snackbar` | `SoeToast.show` |
| `raw_material_button` | `SoeButton` / `SoeIconButton` |
| `raw_text_field` | `SoeTextField` / `SoePasswordField` / `SoeSearchField` |
| `raw_dialog` | `SoeConfirmDialog.show` |
| `gradient` | surface plate (v2) |
| `state_notifier` | `Notifier` / `AsyncNotifier` (skill `soe-viewmodel`) |
| `hardcoded_text` | `Translations.of(context)` (skill `soe-i18n`) |
| `print_call` | `logger` |

## Utilisation

```bash
python3 tools/ds_guard.py                       # état par règle, fichier le plus touché
python3 tools/ds_guard.py --check               # échoue si une règle dépasse son seuil
python3 tools/ds_guard.py --diff refonte/v2     # échoue si un fichier modifié empire ou si un nouveau fichier a une occurrence
python3 tools/ds_guard.py --files lib/a.dart    # chaque occurrence d'un fichier, avec la correction
python3 tools/ds_guard.py --update-baseline     # après un nettoyage ; refuse de monter un seuil
```

## Règles de travail
- Un **fichier créé** par une tâche n'a **aucune** occurrence.
- Un fichier **modifié** n'en a pas plus qu'avant ; la tâche corrige celles de l'écran qu'elle refait.
- Après un nettoyage : `--update-baseline` et commiter le fichier de seuils dans la même PR.
- `--allow-increase` : seulement dans le commit qui ajoute une règle ou élargit sa détection
  (le code existant est alors compté pour la première fois), jamais pour du code nouveau.
- Le script lit le fichier entier (code reformaté sur plusieurs lignes compris) et ignore les
  commentaires `//`, `///` et `/* */`, mais pas les `//` d'une URL dans une chaîne.
- Ne jamais monter un seuil, ne jamais ajouter une exclusion pour faire passer un écran : une
  exclusion n'est légitime que pour une donnée (ex. couleurs de drapeaux), avec un commentaire.
- Ce que le script ne voit pas (structure qui réinvente une carte, espacement hors grille par
  une constante locale) se vérifie en revue avec `soe-design-system`.

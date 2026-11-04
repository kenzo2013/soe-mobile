---
name: soe-i18n
description: Ajouter ou modifier des textes affichés dans l'app SOE avec slang (lib/i18n/fr.i18n.json et en.i18n.json), clés en anglais, vocabulaire validé (répétiteur, représentant légal, FCFA).
---

# Traductions FR / EN (slang)

Configuration : `slang.yaml` (base `fr`, clés en camelCase, interpolation `{{name}}`).

## Règles
- Tout texte affiché (y compris `semanticsLabel`, `tooltip`, `hintText`, messages de toast et
  d'erreur) passe par `Translations.of(context)` (ou `t` hors widget).
- Clé ajoutée **en même temps** dans `fr.i18n.json` et `en.i18n.json`, puis `dart run slang`.
- Clés en anglais, regroupées par feature puis par écran : `parent.quotes.title`,
  `tutor.sessionReport.submit`, `common.actions.retry`. Pas de clé générique réutilisée pour
  des sens différents.
- Interpolation `{{name}}` ; pluriels slang (`"(one) …"`, `"(other) …"`) ; jamais de concaténation.
- Dates : `DateFormat(…, locale)` ; montants : helper commun `formatFcfa(64000)` → `64 000 FCFA`
  (espace insécable), à créer dans `lib/core/` à sa première utilisation.
- Textes métier venant de l'API (libellés de statut, messages 409/422) : affichés tels quels,
  le serveur les traduit selon `Accept-Language`.

## Vocabulaire validé

| Français | Anglais | Interdit |
|---|---|---|
| répétiteur / répétitrice | tutor | « tuteur » |
| représentant légal | legal guardian | « tuteur légal » |
| séance | session | |
| procès-verbal (PV) | session report | |
| devis | quote | |
| Vérifié SOE | SOE verified | « casier judiciaire », « garants » |

Ton : vouvoiement, phrases courtes, mots simples ; messages d'erreur qui disent quoi faire.

## Vérifier
- `python3 tools/ds_guard.py --files <fichiers>` : règle `hardcoded_text`.
- `dart run slang analyze` : clés manquantes en anglais et clés inutilisées.
- Lancer l'app en anglais et parcourir l'écran : rien en dur, rien de coupé.

---
name: soe-component
description: Créer ou étendre un widget partagé Soe* du design system mobile (API, variantes, états, tokens, accessibilité, test, golden) en miroir du composant web Soe::<Name>Component. À utiliser dès qu'un écran a besoin d'un élément que le design system ne couvre pas.
---

# Créer ou étendre un widget `Soe*`

## Avant
1. Chercher dans `lib/core/widgets/` et dans le tableau de la skill `soe-design-system` : étendre
   un widget existant (nouvelle variante) vaut mieux qu'en créer un proche.
2. Ouvrir le composant dans le Studio (rubrique *Composants*) : variantes, tailles, états
   (défaut, pressé, désactivé, chargement, erreur, focus), comportement en tablette.
3. Vérifier le composant web `Soe::<Name>Component` du dépôt `soe` s'il existe : **même nom,
   mêmes variantes, mêmes noms d'arguments** (en camelCase côté Dart).

## Règles
- Fichier `lib/core/widgets/soe_<name>.dart`, classe `Soe<Name>`, `const` constructeur.
- Variantes en `enum` (`SoeButtonVariant.primary`), jamais en booléens multiples.
- Uniquement des tokens `AppPalette`, `AppTypography`, `AppSpacing`, `AppRadius` ; pas de
  dégradé ni d'ombre décorative (v2).
- Aucun texte interne en dur : les libellés arrivent en paramètres ; les textes par défaut
  (« Réessayer ») viennent de `Translations.of(context)`.
- Accessibilité intégrée : cible ≥ 44 × 44, `Semantics(button: true, label: …)` pour les
  éléments sans texte, état désactivé annoncé, contraste AA, prise en charge du texte agrandi
  (`MediaQuery.textScaler` jusqu'à 1,3 sans débordement).
- Aucune logique métier, aucun provider lu dans un widget `Soe*` : il reçoit des valeurs et des callbacks.
- ≤ 300 lignes ; au-delà, découper en sous-widgets privés.

## Livrer avec
- Test de widget : rendu de chaque variante, callbacks, état désactivé, `Semantics`.
- Golden (skill `soe-widget-test-golden`) : une planche avec toutes les variantes et états,
  en clair, à 390 de large, texte normal et agrandi.
- Ajout de la ligne dans le tableau de `soe-design-system`.
- Si le composant web n'existe pas encore : le signaler dans le rendu de la tâche pour qu'il
  soit créé dans le même lot.

---
name: soe-tab-shell
description: Mettre en place ou modifier la navigation par onglets SOE selon le rôle (parent, répétiteur actif, répétiteur pas encore actif) avec go_router StatefulShellRoute, barre d'onglets en mobile et rail en tablette.
---

# Navigation par onglets

Décision v2 (Studio, rubrique *Navigation*) : chaque rôle a sa barre d'onglets ; un compte
parent + répétiteur bascule de rôle depuis « Plus ».

| Rôle | Onglets |
|---|---|
| Parent | Accueil · Planning · Enfants · Paiements · Plus |
| Répétiteur actif | Aujourd'hui · Planning · Élèves · Revenus · Plus |
| Répétiteur pas encore actif (dossier en cours) | Dossier · Offres · Candidatures · Plus |

La cloche des notifications est en haut de chaque page racine, pas dans un onglet.

## Mise en œuvre

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, shell) => RoleShell(shell: shell, tabs: parentTabs),
  branches: [
    StatefulShellBranch(routes: parentHomeRoutes()),
    StatefulShellBranch(routes: parentPlanningRoutes()),
    // one branch per tab, routes declared in each feature (skill soe-route)
  ],
);
```

- Un shell par jeu d'onglets ; le guard (`route_guards.dart`) envoie vers le bon shell selon le
  rôle courant **et** le statut du répétiteur (actif ou non).
- `RoleShell` : `SoeBottomNav` sous 600 px de large, `NavigationRail` habillé aux tokens
  (ou `SoeNavRail` à créer avec `soe-component`) au-delà.
- Chaque onglet garde sa pile (retour à l'onglet = même page) ; retaper l'onglet actif revient
  à sa racine (`shell.goBranch(index, initialLocation: index == shell.currentIndex)`).
- Pages de détail plein écran (paiement, signature, pointage) : déclarées hors du shell, avec
  `parentNavigatorKey` racine, pour masquer la barre.
- Libellés via `Translations.of(context)` ; icône + texte toujours visibles ; badge de compteur
  sur un onglet seulement si le Studio le prévoit.
- Changement de rôle : `switchRole` côté API, puis `context.go` vers la racine du nouveau shell.

## Tests
- Le guard envoie chaque rôle et statut vers le bon shell.
- Les onglets affichés correspondent au tableau ci-dessus (test de widget).
- Goldens de la barre à 390 et du rail à 834.

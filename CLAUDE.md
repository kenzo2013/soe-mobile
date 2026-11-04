# CLAUDE.md

⛔ **Les règles de ce dépôt vivent dans [`docs/CLAUDE.md`](docs/CLAUDE.md).** Ce fichier n'est
qu'un panneau : le dupliquer ferait diverger les deux.

🔴 **Règle 0** : *tout le code s'écrit en ANGLAIS* — classes, méthodes, variables, **commentaires**,
noms de fichiers, routes. Seuls les textes AFFICHÉS restent en français (`lib/i18n/*.i18n.json`).

🎨 **Tout écran se construit avec les widgets `Soe*` et les tokens `App*`** (skill `soe-design-system`).
Écart mesuré : `python3 tools/ds_guard.py --check`.

✅ Avant de rendre : `dart format --set-exit-if-changed . && flutter analyze && flutter test && python3 tools/ds_guard.py --check`.

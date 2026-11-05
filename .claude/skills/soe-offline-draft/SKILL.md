---
name: soe-offline-draft
description: Permettre de remplir un formulaire SOE sans réseau et de l'envoyer plus tard (PV de séance, pointage, formulaires longs) avec un brouillon local, une file d'envoi idempotente et un état visible. À utiliser pour tout formulaire qu'un répétiteur ou un parent peut remplir en zone de mauvaise couverture.
---

# Brouillon hors ligne

Cas d'usage prioritaires : **PV de séance** (rédigé juste après la séance, souvent sans
réseau), **pointage** (arrivée / départ), demande de cours en plusieurs étapes.

## Principe
1. Chaque saisie est enregistrée localement au fil de l'eau (brouillon), clé =
   type + identifiant métier (`session_report:<sessionId>`).
2. « Envoyer » met l'envoi en file s'il n'y a pas de réseau ; l'écran affiche « En attente
   d'envoi » (badge du design system), jamais un faux succès.
3. Au retour du réseau (et au lancement de l'app), la file est rejouée dans l'ordre.
4. Chaque envoi porte une **clé d'idempotence** (UUID générée à la création du brouillon,
   en-tête `Idempotency-Key`) : le serveur ignore un doublon, donc rejouer est sans risque.
5. Succès → brouillon supprimé. Erreur 422 → le brouillon redevient modifiable avec les
   erreurs par champ. Erreur 409 (déjà envoyé, PV déjà validé) → brouillon supprimé, message.

## Mise en œuvre
- Stockage : un `DraftStore` dans `lib/core/storage/` (JSON par clé) au-dessus de
  `shared_preferences` pour du texte court ; **jamais** de données sensibles en clair (rien
  dans `shared_preferences` qui vienne de `flutter_secure_storage`). Photos jointes : copiées
  dans le dossier de l'app, chemin dans le brouillon.
- File : `OutboxRepository` (Domain) + implémentation Data ; déclenchée par un provider qui
  écoute la connectivité et le cycle de vie de l'app.
- Pointage : l'heure et la position sont **celles du moment de la saisie**, envoyées avec
  l'action ; le serveur applique la règle des 150 m et l'heure d'origine.
- Durée de vie : un brouillon non envoyé est signalé au bout de 24 h (délai du PV) et jamais
  effacé sans action de l'utilisateur.

## Tests
- Brouillon sauvé puis restauré après redémarrage (fausse persistance).
- Envoi sans réseau → en file ; retour du réseau → envoyé une seule fois.
- Double rejeu → une seule création (même clé d'idempotence).
- 422 → brouillon modifiable avec erreurs ; 409 → brouillon supprimé.

## Côté serveur
Les endpoints concernés acceptent `Idempotency-Key` (à prévoir dans la skill Rails
`soe-api-v2-endpoint` pour le PV et le pointage).

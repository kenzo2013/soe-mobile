# **Cahier des Charges \- Application Mobile SOE**

**Solution of Education \- Application Mobile iOS & Android**

| Information          | Detail                                           |
| :------------------- | :----------------------------------------------- |
| **Projet**           | Application mobile SOE (Solution of Education)   |
| **Version**          | 1.1                                              |
| **Date**             | 20 avril 2026                                    |
| **Plateforme**       | iOS (iPhone \+ iPad) & Android (Phone \+ Tablet) |
| **API Backend**      | REST API v1 \- api.jeteste.site/api/v1           |
| **Authentification** | JWT (JSON Web Token) \- 30 jours d’expiration    |

---

## **Table des matieres**

1. [Presentation du projet](#bookmark=id.g2ygfj9qaiyq)

2. [Charte graphique et design system](#bookmark=id.3nc89o8itpf4)

3. [Architecture fonctionnelle](#bookmark=id.jyixlx4zwfmr)

4. [Parcours utilisateur Parent](#bookmark=id.rg4blgmf6x4n)

5. [Parcours utilisateur Tuteur](#bookmark=id.d1yeemmlv41o)

6. [Fonctionnalites communes](#bookmark=id.beuqrxcwhhxa)

7. [Specifications API detaillees](#bookmark=id.dub103nyov8k)

8. [Notifications push](#bookmark=id.82053kdlm775)

9. [Assets Store (App Store & Google Play)](#bookmark=id.d99sc3kn20kv)

10. [Exigences techniques](#bookmark=id.4kic0ai9by7)

11. [Annexes](#bookmark=id.irfchbbeyvnj)

---

## **1\. Presentation du projet**

### **1.1 Contexte**

SOE (Solution of Education) est une plateforme de tutorat a domicile au Cameroun. Elle connecte des parents d’eleves avec des tuteurs certifies pour du soutien scolaire personnalise. L’application web existe deja en production sur app.jeteste.site.

### **1.2 Objectif de l’application mobile**

Developper une application mobile native (iOS \+ Android) qui reproduit les fonctionnalites essentielles de la plateforme web pour les deux profils utilisateurs : \- **Parent** : gerer ses enfants, demander des reservations de tutorat, suivre les seances, payer, noter les tuteurs \- **Tuteur** : completer son profil, consulter ses seances, soumettre des rapports, gerer ses paiements

### **1.3 Utilisateurs cibles**

| Profil     | Description                              | Actions principales                                  |
| :--------- | :--------------------------------------- | :--------------------------------------------------- |
| **Parent** | Parent/tuteur legal, 25-55 ans, Cameroun | Inscrire enfants, reserver des tuteurs, payer, noter |
| **Tuteur** | Enseignant/etudiant qualifie, 20-45 ans  | Completer profil, enseigner, rapporter, etre paye    |

### **1.4 Multi-role**

Un utilisateur peut avoir les deux roles (parent ET tuteur). L’app doit permettre le basculement entre les roles via un switch dans le profil.

---

## **2\. Charte graphique et design system**

### **2.1 Palette de couleurs**

| Nom                        | Code hex | Utilisation                                       |
| :------------------------- | :------- | :------------------------------------------------ |
| **Primaire (Or)**          | \#FFB000 | Boutons CTA, accents, badges, etoiles de notation |
| **Secondaire (Bleu-vert)** | \#035E7B | Navigation active, headers, boutons secondaires   |
| **Texte principal**        | \#010814 | Titres, corps de texte                            |
| **Texte secondaire**       | \#526684 | Sous-titres, labels, textes explicatifs           |
| **Texte tertiaire**        | \#A3BCE2 | Placeholders, labels legers, icones inactives     |
| **Fond principal**         | \#FCFDFF | Fond des cartes, conteneurs                       |
| **Fond clair**             | \#F5F9FF | Fond de page, hover states                        |
| **Fond accent**            | \#DCEAFF | Sections mises en avant, en-tetes de tableaux     |
| **Fond page**              | \#EAF0F9 | Fond general du dashboard                         |
| **Succes**                 | \#028226 | Actions positives, statut complete                |
| **Erreur**                 | \#FF3F3F | Erreurs, suppressions, alertes                    |
| **Avertissement**          | \#FF7A00 | Etats en attente, avertissements                  |

### **2.2 Typographie**

| Element            | Police  | Poids           | Taille  |
| :----------------- | :------ | :-------------- | :------ |
| **Titres H1**      | Poppins | Bold (700)      | 24-28px |
| **Titres H2**      | Poppins | Semi-bold (600) | 20-22px |
| **Titres H3**      | Poppins | Semi-bold (600) | 18px    |
| **Corps de texte** | Poppins | Regular (400)   | 14-16px |
| **Labels**         | Poppins | Regular (400)   | 12-14px |
| **Captions**       | Poppins | Light (300)     | 10-12px |
| **Boutons**        | Poppins | Semi-bold (600) | 14px    |

### **2.3 Composants UI**

#### _Boutons_

| Type           | Fond        | Texte    | Rayon         | Exemple             |
| :------------- | :---------- | :------- | :------------ | :------------------ |
| **Primaire**   | \#FFB000    | \#010814 | 59px (pilule) | “Demander un devis” |
| **Secondaire** | \#035E7B    | \#FFFFFF | 24px          | “Envoyer”           |
| **Danger**     | \#FF3F3F    | \#FFFFFF | 8px           | “Supprimer”         |
| **Outline**    | Transparent | \#035E7B | 8px           | “Annuler”           |
| **Ghost**      | Transparent | \#A3BCE2 | 0px           | “Voir plus”         |

#### _Cartes_

- Fond : \#FCFDFF

- Padding : 16-20px

- Rayon de bordure : 10-15px

- Ombre : 0px 2px 8px rgba(6, 22, 41, 0.1)

#### _Avatars_

- Tailles : 36px (mini), 52px (liste), 92px (profil), 116px (detail)

- Forme : Circulaire (border-radius: 50%)

- Fallback : Image par defaut grise avec silhouette

#### _Champs de formulaire_

- Fond : \#FCFDFF

- Bordure : 1px \#A3BCE2, focus: \#035E7B

- Rayon : 8px

- Padding : 12px 16px

- Placeholder : \#A3BCE2

#### _Etoiles de notation_

- Remplie : \#FFB000 (etoile pleine)

- Vide : \#D1D5DB (gris clair)

- Taille : 24px (selection), 16px (affichage)

### **2.4 Icones**

L’application utilise une bibliotheque d’icones SVG personnalisee. Le designer doit creer des icones coherentes avec le style existant : \- Trait fin (1.5-2px) \- Style lineaire \- Couleur adaptative (gris inactif, blanc actif, primaire accent)

### **2.5 Animations et transitions**

- Navigation entre ecrans : slide horizontal (300ms)

- Apparition d’elements : fade-in \+ slide-up (300ms)

- Hover/Press : scale(0.97) avec transition 150ms

- Pull-to-refresh : animation native

- Skeleton loading : animation de shimmer sur fond \#EAF0F9

---

## **3\. Architecture fonctionnelle**

### **3.1 Arborescence des ecrans**

App SOE  
|  
\+-- Onboarding (3 ecrans)  
|  
\+-- Auth  
| \+-- Connexion (email \+ mot de passe)  
| \+-- Inscription (parent ou tuteur)  
| \+-- Mot de passe oublie  
| \+-- Confirmation email  
|  
\+-- \[PARENT\]  
| \+-- Dashboard  
| | \+-- Resume du jour (seances, reservations recentes)  
| | \+-- Acces rapide aux enfants  
| |  
| \+-- Mes enfants  
| | \+-- Liste des enfants  
| | \+-- Fiche enfant (detail \+ matiere \+ emploi du temps)  
| | \+-- Ajouter/modifier un enfant  
| | \+-- Information tuteur (profil public du tuteur)  
| | \+-- Identite  
| | \+-- Formations  
| | \+-- Disponibilites  
| | \+-- Experiences  
| | \+-- Matieres  
| | \+-- Avis  
| |  
| \+-- Reservations  
| | \+-- Liste des reservations  
| | \+-- Detail reservation (devis, statut, programme)  
| | \+-- Nouvelle reservation (multi-etapes)  
| | \+-- Accepter / Negocier / Rejeter un devis  
| |  
| \+-- Seances  
| | \+-- Liste des seances (calendrier \+ liste)  
| | \+-- Detail seance  
| | \+-- Rapport de seance (consultation \+ validation)  
| |  
| \+-- Paiements  
| | \+-- Historique des paiements  
| | \+-- Paiement en ligne (MTN MoMo / Orange Money)  
| | \+-- Suivi du statut de paiement  
| | \+-- Telecharger recu (PDF)  
| |  
| \+-- Avis  
| | \+-- Donner un avis (etoiles \+ commentaire \+ matieres)  
| | \+-- Modifier un avis existant  
| |  
| \+-- Programmes proposes  
| | \+-- Liste des programmes de cours  
| | \+-- Detail d'un programme  
| |  
| \+-- Invitations  
| | \+-- Inviter un second parent  
| | \+-- Liste des invitations  
| |  
| \+-- Contrats  
| \+-- Liste des contrats  
| \+-- Detail \+ signature electronique  
| \+-- Avenants  
|  
\+-- \[TUTEUR\]  
| \+-- Dashboard  
| | \+-- Seances du jour  
| | \+-- Statistiques (eleves, seances, en attente)  
| |  
| \+-- Mon profil  
| | \+-- Description / Bio  
| | \+-- Formations (CRUD)  
| | \+-- Experiences professionnelles (CRUD)  
| | \+-- Pieces d'identite (CRUD \+ upload photos)  
| | \+-- Matieres enseignees par niveau (CRUD)  
| | \+-- Disponibilites hebdomadaires (CRUD)  
| |  
| \+-- Offres d'emploi  
| | \+-- Liste des offres publiees  
| | \+-- Detail offre  
| | \+-- Postuler a une offre  
| |  
| \+-- Mes cours  
| | \+-- Liste des cours actifs (reservations assignees)  
| | \+-- Detail cours (eleve, matieres, emploi du temps)  
| | \+-- Gerer les horaires  
| |  
| \+-- Seances  
| | \+-- Liste des seances  
| | \+-- Detail seance  
| | \+-- Modifier une seance  
| | \+-- Soumettre un rapport (avec signature)  
| |  
| \+-- Remunerations  
| | \+-- Historique des paiements recus  
| | \+-- Telecharger recu (PDF)  
| |  
| \+-- Informations de paiement  
| | \+-- Ajouter compte bancaire  
| | \+-- Ajouter mobile money  
| | \+-- Definir methode par defaut  
| |  
| \+-- Contrats  
| \+-- Liste des contrats  
| \+-- Detail \+ signature electronique  
| \+-- Avenants  
|  
\+-- \[COMMUN\]  
 \+-- Mon compte  
 | \+-- Informations personnelles (nom, email, telephone, photo)  
 | \+-- Changer le mot de passe  
 | \+-- Adresse  
 | \+-- Switch de role (si multi-role)  
 | \+-- Preferences de notification  
 |  
 \+-- Notifications  
 | \+-- Liste des notifications (avec filtre lu/non-lu)  
 | \+-- Detail notification  
 | \+-- Marquer tout comme lu  
 |  
 \+-- Deconnexion

---

## **4\. Parcours utilisateur Parent**

### **4.1 Inscription et connexion**

#### _Ecran : Inscription Parent_

**Workflow :** 1\. L’utilisateur choisit “Je suis parent” 2\. Renseigne : civilite, nom, prenom, email, telephone, mot de passe 3\. Accepte les CGU (lien vers page web CGU) 4\. Renseigne son adresse (avec champ autocomplete Google Places) 5\. Soumet le formulaire 6\. Recoit un email de confirmation 7\. Confirme son email → redirige vers le dashboard

**Endpoint :** POST /api/v1/users/register

{  
 "user": {  
 "email": "parent@example.com",  
 "password": "SecureP@ss1",  
 "password_confirmation": "SecureP@ss1",  
 "first_name": "Jean",  
 "last_name": "Dupont",  
 "civility": "Mr",  
 "phone": "+237699000000",  
 "accept_cgu": **true**,  
 "role": "parent",  
 "lang": "fr",  
 "address_attributes": {  
 "neighborhood": "Akwa",  
 "city": "Douala",  
 "country": "Cameroun",  
 "country_code": "CM"  
 }  
 }  
}

#### _Ecran : Connexion_

**Workflow :** 1\. Saisie email \+ mot de passe 2\. Appel API login 3\. Stockage du JWT token en local (Keychain iOS / EncryptedSharedPreferences Android) 4\. Redirection vers le dashboard du role actif

**Endpoint :** POST /api/v1/users/login

{  
 "user": { "email": "parent@example.com", "password": "SecureP@ss1" }  
}

**Reponse :** { "data": { ...user }, "accessToken": "eyJhbG..." }

#### _Ecran : Mot de passe oublie_

**Workflow :** 1\. Saisie de l’email 2\. Envoi de la demande 3\. Message de confirmation “Un email vous a ete envoye”

**Endpoint :** POST /api/v1/users/password

{ "user": { "email": "parent@example.com" } }

---

### **4.2 Dashboard Parent**

#### _Ecran : Tableau de bord_

**Contenu :** \- Message de bienvenue avec le prenom \- Section “Seances du jour” : liste des seances planifiees aujourd’hui avec heure, tuteur, eleve \- Section “Reservations recentes” : 5 dernieres reservations avec statut \- Bouton CTA “Demander un devis” (primaire, or) \- Liste rapide des enfants (avatars cliquables)

**Endpoint :** GET /api/v1/parents

{  
 "data": {  
 "students": \[**...**\],  
 "recent_reservations": \[**...**\],  
 "today_sessions": \[**...**\]  
 }  
}

---

### **4.3 Gestion des enfants**

#### _Ecran : Liste des enfants_

**Contenu :** \- Grille/liste de cartes : photo, nom complet, classe, age \- Bouton “+” pour ajouter un enfant \- Tap sur une carte → Fiche de l’enfant

**Endpoint :** GET /api/v1/parents/students

#### _Ecran : Ajouter/Modifier un enfant_

**Formulaire :** \- Photo (camera ou galerie) \- Prenom, Nom \- Age, Genre (selection male/female) \- Niveau d’education, Section \- Classe (picker parmi les SchoolClasses) \- Adresse (avec autocomplete)

**Endpoints :** \- POST /api/v1/parents/students \- PATCH /api/v1/parents/students/:id

#### _Ecran : Information du tuteur (profil public)_

**Onglets :** 1\. **Identite** : Photo, nom, categorie, bio, telephone, email, pieces d’identite 2\. **Formations** : Liste des diplomes (categorie, niveau, specialite, date) 3\. **Disponibilites** : Grille hebdomadaire des creneaux disponibles 4\. **Experiences** : Liste des postes occupes 5\. **Matieres** : Matieres enseignees par niveau de classe 6\. **Avis** : Note moyenne, nombre d’avis, liste des avis avec etoiles

**Endpoint :** GET /api/v1/parents/students/:id/tutor_information/:tutor_id

---

### **4.4 Reservations**

#### _Ecran : Liste des reservations_

**Contenu :** \- Liste avec : reference, statut (badge couleur), montant, date \- Filtre par statut \- Pull-to-refresh

**Endpoint :** GET /api/v1/parents/reservations

#### _Ecran : Nouvelle reservation (multi-etapes)_

**Etape 1 : Selectionner l’enfant** \- Choisir parmi les enfants existants ou en creer un nouveau

**Etape 2 : Definir les besoins** \- Date de debut estimee (date picker) \- Frequence (nombre de seances par semaine) \- Genre prefere du tuteur (Homme / Femme / Pas de preference) \- Matieres (selection multiple parmi les sujets disponibles)

**Etape 3 : Confirmation** \- Resume de la demande \- Bouton “Envoyer la demande”

**Endpoint :** POST /api/v1/parents/reservations

{  
 "reservation": {  
 "tutoring_requests_attributes": \[{  
 "student_id": "uuid",  
 "estimated_start_date": "2026-05-01",  
 "frequency": 3,  
 "preferred_tutor_gender": "no_preference",  
 "subject_ids": \["uuid1", "uuid2"\]  
 }\]  
 }  
}

#### _Ecran : Detail reservation_

**Contenu :** \- Informations generales : reference, statut, montant total \- Liste des demandes de tutorat : eleve, matieres, frequence, tuteur assigne \- Programme de cours (si disponible) \- Actions selon le statut du devis : \- proposed_price → Boutons : Accepter / Negocier / Rejeter \- accepted → Badge “Accepte” \- draft → “En attente de devis”

**Endpoints :** \- GET /api/v1/parents/reservations/:id \- PATCH /api/v1/parents/reservations/:id/accept \- PATCH /api/v1/parents/reservations/:id/negotiate \- PATCH /api/v1/parents/reservations/:id/reject

---

### **4.5 Seances**

#### _Ecran : Liste des seances_

**Deux vues :** 1\. **Vue calendrier** : calendrier mensuel avec points colores sur les jours avec seances 2\. **Vue liste** : cartes avec date, heure, tuteur, eleve, statut

**Endpoint :** GET /api/v1/parents/sessions

#### _Ecran : Detail seance_

**Contenu :** \- Date, heure de debut et fin \- Tuteur (nom \+ photo) \- Eleve (nom \+ photo) \- Statut (pending / completed / approved / rejected) \- Commentaire du tuteur \- Lien vers le rapport de seance (si disponible)

**Endpoint :** GET /api/v1/parents/sessions/:id/details

#### _Ecran : Rapport de seance_

**Contenu :** \- Informations de la seance (date, heures) \- Contenu de la seance (proceedings \- texte riche) \- Commentaire du tuteur \- Signature du tuteur (image) \- Statut de validation \- Actions : Valider / Rejeter (si non encore valide)

**Endpoints :** \- GET /api/v1/parents/sessions/:session_id/session_reports/:id \- PATCH /api/v1/parents/sessions/:session_id/session_reports/:id

---

### **4.6 Paiements**

#### _Ecran : Historique des paiements_

**Contenu :** \- Liste : montant, methode, statut (badge), periode, numero de recu \- Filtre par statut (tous / en attente / complete / echoue)

**Endpoint :** GET /api/v1/parents/payments

#### _Ecran : Paiement en ligne_

**Workflow :** 1\. Selectionner la reservation a payer 2\. Choisir le canal : MTN MoMo ou Orange Money 3\. Saisir le numero de telephone 4\. Saisir le montant et la periode 5\. Confirmer → initiation du paiement 6\. Ecran d’attente avec polling du statut 7\. Confirmation de succes ou echec

**Endpoints :** \- POST /api/v1/parents/payments/create_online

{  
 "reservation_id": "uuid",  
 "channel": "cm.mtn",  
 "phone_number": "+237670000000",  
 "amount": 50000,  
 "payment_period": "2026-05-01"  
}

- GET /api/v1/parents/payments/:id/check_status (polling toutes les 5 secondes)

- GET /api/v1/parents/payments/:id/download_receipt (PDF)

---

### **4.7 Avis sur les tuteurs**

#### _Ecran : Donner un avis_

**Contenu :** \- Photo et nom du tuteur \- Selection d’etoiles (1-5) avec animation hover/tap \- Selection des matieres concernees (checkboxes) \- Zone de commentaire (textarea) \- Boutons : Envoyer / Annuler

**Endpoint :** POST /api/v1/parents/reviews

{  
 "review": {  
 "tutor_id": "uuid",  
 "rating": 4,  
 "comment": "Excellent tuteur, tres pedagogue.",  
 "subject_ids": \["uuid1"\]  
 }  
}

**Regle metier :** Un seul avis actif par couple parent-tuteur. La modification archive l’ancien et cree un nouveau.

#### _Ecran : Modifier un avis_

- Meme formulaire pre-rempli

- **Endpoint :** PATCH /api/v1/parents/reviews/:id

---

### **4.8 Contrats**

#### _Ecran : Liste des contrats_

**Contenu :** \- Reference, date, statut de signature \- Nombre d’avenants

**Endpoint :** GET /api/v1/common/contracts

#### _Ecran : Detail contrat \+ Signature_

**Contenu :** \- Document PDF integre \- Zone de signature electronique (canvas tactile) \- Bouton “Signer”

**Endpoints :** \- GET /api/v1/common/contracts/:id \- PATCH /api/v1/common/contracts/:id (avec fichier signature)

---

## **5\. Parcours utilisateur Tuteur**

### **5.1 Dashboard Tuteur**

#### _Ecran : Tableau de bord_

**Contenu :** \- Section “Seances du jour” : liste des seances planifiees \- Statistiques rapides : \- Nombre total d’eleves \- Nombre total de seances \- Seances en attente \- Seances completees \- Acces rapide aux actions frequentes

**Endpoint :** GET /api/v1/tutors

{  
 "data": {  
 "today_sessions": \[**...**\],  
 "stats": {  
 "total_students": 12,  
 "total_sessions": 48,  
 "pending_sessions": 3,  
 "completed_sessions": 45  
 }  
 }  
}

---

### **5.2 Profil du tuteur**

#### _Ecran : Description / Bio_

**Contenu :** \- Editeur de texte riche pour la description personnelle \- Apercu en temps reel

**Endpoints :** \- GET /api/v1/tutors/descriptions \- POST /api/v1/tutors/descriptions \- PATCH /api/v1/tutors/descriptions/:id

#### _Ecran : Formations (CRUD)_

**Formulaire :** \- Categorie (type de diplome) \- Niveau d’etude (Licence, Master, Doctorat, etc.) \- Domaine de formation \- Specialite \- Date d’obtention

**Endpoints :** \- GET /api/v1/tutors/trainings \- POST /api/v1/tutors/trainings \- PATCH /api/v1/tutors/trainings/:id \- DELETE /api/v1/tutors/trainings/:id

#### _Ecran : Experiences professionnelles (CRUD)_

**Formulaire :** \- Poste occupe \- Entreprise \- Poste actuel (toggle)

**Endpoints :** \- GET /api/v1/tutors/works \- POST /api/v1/tutors/works \- PATCH /api/v1/tutors/works/:id \- DELETE /api/v1/tutors/works/:id

#### _Ecran : Pieces d’identite (CRUD)_

**Formulaire :** \- Date de naissance (date picker) \- Type de document (Passeport, CNI, etc.) \- Date d’expiration \- Photos du document (camera ou galerie, upload multiple)

**Endpoints :** \- GET /api/v1/tutors/identities \- POST /api/v1/tutors/identities (multipart/form-data) \- PATCH /api/v1/tutors/identities/:id \- DELETE /api/v1/tutors/identities/:id

#### _Ecran : Matieres enseignees_

**Formulaire :** \- Selection de la classe/niveau \- Selection des matieres (checkboxes multiples)

**Endpoints :** \- GET /api/v1/tutors/tutor_courses \- POST /api/v1/tutors/tutor_courses \- PATCH /api/v1/tutors/tutor_courses/:id \- DELETE /api/v1/tutors/tutor_courses/:id

#### _Ecran : Disponibilites hebdomadaires_

**Interface :** \- Grille 7 jours (Lundi → Dimanche) \- Pour chaque jour : ajouter des creneaux horaires (de HH:MM a HH:MM) \- Bouton “+” pour ajouter un creneau \- Bouton “X” pour supprimer un creneau

**Endpoints :** \- GET /api/v1/tutors/availabilities \- POST /api/v1/tutors/availabilities \- PATCH /api/v1/tutors/availabilities/:id \- DELETE /api/v1/tutors/availabilities/:id

---

### **5.3 Offres d’emploi**

#### _Ecran : Liste des offres_

**Contenu :** \- Cartes : description, prix, date de debut, matieres (badges), localisation \- Filtres possibles

**Endpoint :** GET /api/v1/tutors/jobs

#### _Ecran : Detail offre_

**Contenu :** \- Description complete \- Prix propose \- Date de debut \- Matieres requises (badges) \- Classes concernees \- Localisation (quartier, ville) \- Bouton “Postuler” (si pas deja postule)

**Endpoints :** \- GET /api/v1/tutors/jobs/:id \- POST /api/v1/tutors/candidacies { "job_id": "uuid" }

---

### **5.4 Mes cours (Tutoring Courses)**

#### _Ecran : Liste des cours actifs_

**Contenu :** \- Reservations assignees avec : reference, statut, date \- Pour chaque : liste des demandes de tutorat (eleve, matieres, horaires)

**Endpoint :** GET /api/v1/tutors/tutoring_courses

#### _Ecran : Detail eleve dans un cours_

**Contenu :** \- Informations de l’eleve (nom, age, genre, classe) \- Emploi du temps des seances (jours \+ horaires) \- Matieres concernees

**Endpoint :** GET /api/v1/tutors/students/:id?reservation_id=X

#### _Ecran : Gerer les horaires_

**Interface :** \- Liste des jours avec creneaux \- Modifier les horaires pour un eleve specifique

**Endpoint :** POST /api/v1/tutors/tutoring_courses/manage_schedules

---

### **5.5 Seances du tuteur**

#### _Ecran : Liste des seances_

**Endpoint :** GET /api/v1/tutors/sessions

#### _Ecran : Detail seance_

**Contenu :** \- Informations de la seance \- Eleve concerne \- Reservation associee \- editable? : indique si la seance peut etre modifiee (\> 24h avant) \- report_available? : indique si le rapport peut etre soumis (\> 10 min apres debut) \- Actions : Modifier seance / Soumettre rapport

**Endpoint :** GET /api/v1/tutors/sessions/:id/details

#### _Ecran : Soumettre un rapport de seance_

**Formulaire :** \- Date de la seance \- Heure de debut et fin effectives \- Contenu de la seance (texte riche \- ce qui a ete couvert) \- Zone de signature (canvas tactile, le tuteur signe avec le doigt) \- Bouton “Soumettre”

**Endpoint :** POST /api/v1/tutors/sessions/:session_id/session_reports

{  
 "session_report": {  
 "date": "2026-05-15",  
 "start_at": "14:00",  
 "end_at": "16:00",  
 "proceedings": "Revision des fractions et exercices pratiques.",  
 "signature": "\<fichier image de la signature\>"  
 }  
}

---

### **5.6 Remunerations**

#### _Ecran : Historique des remunerations_

**Contenu :** \- Liste : montant, periode, statut (en attente / paye), date de paiement \- Telecharger le recu (PDF)

**Endpoints :** \- GET /api/v1/tutors/remunerations \- GET /api/v1/tutors/remunerations/:id/download_receipt

---

### **5.7 Informations de paiement**

#### _Ecran : Mes methodes de paiement_

**Contenu :** \- Liste des methodes enregistrees (mobile money ou banque) \- Badge “Par defaut” sur la methode principale \- Actions : Ajouter / Modifier / Supprimer / Definir par defaut

#### _Ecran : Ajouter Mobile Money_

**Formulaire :** \- Numero de telephone \- Operateur (Orange Money / MTN Money)

**Endpoint :** POST /api/v1/tutors/payment_informations

{ "type": "mobile_payment", "mobile_payment": { "phone": "+237670000000", "mobile_operator": "MTN Money" } }

#### _Ecran : Ajouter Compte bancaire_

**Formulaire :** \- Titulaire du compte, Nom de la banque \- IBAN, BIC \- Code banque, Code agence, Numero de compte, Cle

**Endpoint :** POST /api/v1/tutors/payment_informations

{ "type": "bank", "bank_information": { "account_holder": "Jean Dupont", "iban": "CM...", "bic": "..." } }

---

## **6\. Fonctionnalites communes**

### **6.1 Mon compte**

#### _Ecran : Informations personnelles_

**Formulaire :** \- Photo de profil (camera / galerie) \- Prenom, Nom \- Civilite \- Telephone \- Langue preferee (FR / EN)

**Endpoints :** \- GET /api/v1/current_user \- PATCH /api/v1/current_user

#### _Ecran : Changer le mot de passe_

**Formulaire :** \- Mot de passe actuel \- Nouveau mot de passe \- Confirmation

**Endpoint :** PATCH /api/v1/current_user/update_password

#### _Ecran : Adresse_

**Formulaire :** \- Adresse (autocomplete Google Places) \- Complement d’adresse \- Quartier, Ville, Region \- Point de repere \- Pays

**Endpoints :** \- GET /api/v1/common/address \- PATCH /api/v1/common/address

#### _Ecran : Switch de role_

**Contenu :** \- Role actuel affiche \- Toggle ou bouton pour basculer (si multi-role) \- Bouton “Ajouter un role” (si mono-role)

**Endpoints :** \- PATCH /api/v1/role_switch { "role": "tutor" } \- POST /api/v1/role_addition { "role": "tutor" }

#### _Ecran : Preferences de notification_

**Contenu :** \- Grille par categorie (reservation, session, paiement, etc.) \- Pour chaque : toggles Email / Push \- Sauvegarde automatique au changement

**Endpoints :** \- GET /api/v1/common/notification_preferences \- PATCH /api/v1/common/notification_preferences

---

### **6.2 Notifications**

#### _Ecran : Centre de notifications_

**Contenu :** \- Liste des notifications (non-lu en surbrillance \#DCEAFF) \- Filtre : Toutes / Non-lues \- Swipe pour supprimer \- Bouton “Tout marquer comme lu” \- Tap → navigation vers la ressource concernee

**Endpoints :** \- GET /api/v1/common/notifications \- GET /api/v1/common/notifications?filter=unread \- PATCH /api/v1/common/notifications/:id/mark_as_read \- PATCH /api/v1/common/notifications/mark_all_as_read \- DELETE /api/v1/common/notifications/:id

---

## **7\. Specifications API detaillees**

### **7.1 Base URL**

| Environnement  | URL                                                               |
| :------------- | :---------------------------------------------------------------- |
| **Production** | https://api.solutionofeducation.com/api/v1                        |
| **Staging**    | https://api.jeteste.site/api/v1 (meme domaine, config differente) |

### **7.2 Authentification**

Toutes les requetes authentifiees doivent inclure le header :

Authorization: Bearer \<JWT_TOKEN\>

Le token est obtenu via POST /api/v1/users/login et retourne dans le champ accessToken. Le token expire apres **30 jours**.

### **7.3 Format de reponse standard**

**Succes :**

{  
 "status": { "code": 200, "message": "Success" },  
 "data": { }  
}

**Succes pagine :**

{  
 "status": { "code": 200, "message": "Success" },  
 "data": \[ \],  
 "pagination": {  
 "current_page": 1,  
 "per_page": 25,  
 "total_pages": 5,  
 "total_count": 125  
 }  
}

**Note :** La pagination par defaut est de **25 elements par page** (Pagy). Le client peut passer ?page=2 pour naviguer.

**Erreur :**

{  
 "status": { "code": 422, "message": "Description de l'erreur" }  
}

### **7.4 Codes de statut HTTP et gestion des erreurs**

| Code | Signification                            | Declencheur backend                   |
| :--- | :--------------------------------------- | :------------------------------------ |
| 200  | Succes                                   | Reponse standard                      |
| 201  | Ressource creee                          | render_success(..., status: :created) |
| 400  | Parametres invalides                     | ActionController::ParameterMissing    |
| 401  | Token JWT manquant ou invalide           | Token expire ou absent                |
| 403  | Permissions insuffisantes (mauvais role) | CanCan::AccessDenied                  |
| 404  | Ressource introuvable                    | ActiveRecord::RecordNotFound          |
| 409  | Conflit metier (doublon, deja postule)   | ActiveRecord::RecordNotUnique         |
| 422  | Erreurs de validation                    | ActiveRecord::RecordInvalid           |

**Comportement du client mobile face aux erreurs :** \- 401 → Supprimer le token local, rediriger vers l’ecran de connexion \- 403 → Afficher “Acces non autorise”, proposer de changer de role \- 404 → Afficher “Ressource introuvable”, retour arriere \- 409 → Afficher le message serveur (ex: “Vous avez deja un avis actif pour ce tuteur”) \- 422 → Afficher les messages de validation sous les champs concernes \- 400 → Afficher “Requete invalide” (erreur generique)

### **7.5 CORS**

Le serveur accepte les requetes cross-origin sur /api/\* : \- **Origines** : configurees via variable d’environnement ALLOWED_ORIGINS \- **Methodes** : GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD \- **Headers exposes** : Authorization (pour la recuperation du JWT) \- **Headers acceptes** : tous (headers: :any)

**Pour le mobile :** les requetes natives (non-browser) ne sont pas soumises au CORS. Cette section est informative pour les developpeurs web/hybrid.

### **7.6 Tableau recapitulatif des endpoints**

#### _Auth (non authentifie)_

| Methode | Endpoint        | Description        |
| :------ | :-------------- | :----------------- |
| POST    | /users/login    | Connexion          |
| DELETE  | /users/logout   | Deconnexion        |
| POST    | /users/register | Inscription        |
| POST    | /users/password | Reset mot de passe |

#### _Utilisateur courant_

| Methode | Endpoint                      | Description          |
| :------ | :---------------------------- | :------------------- |
| GET     | /current_user                 | Profil utilisateur   |
| PATCH   | /current_user                 | Modifier profil      |
| PATCH   | /current_user/update_password | Changer mot de passe |
| PATCH   | /role_switch                  | Changer de role      |
| POST    | /role_addition                | Ajouter un role      |

#### _Appareils_

| Methode | Endpoint               | Description                 |
| :------ | :--------------------- | :-------------------------- |
| POST    | /user_devices          | Enregistrer appareil (push) |
| PATCH   | /user_devices/activity | MAJ activite appareil       |

#### _Offres publiques_

| Methode | Endpoint  | Description      |
| :------ | :-------- | :--------------- |
| GET     | /jobs     | Liste des offres |
| GET     | /jobs/:id | Detail offre     |

#### _Parent_

| Methode | Endpoint                                          | Description                |
| :------ | :------------------------------------------------ | :------------------------- |
| GET     | /parents                                          | Dashboard                  |
| GET     | /parents/students                                 | Liste enfants              |
| POST    | /parents/students                                 | Ajouter enfant             |
| GET     | /parents/students/:id                             | Detail enfant              |
| PATCH   | /parents/students/:id                             | Modifier enfant            |
| DELETE  | /parents/students/:id                             | Supprimer enfant           |
| GET     | /parents/students/:id/tutor_information/:tutor_id | Profil tuteur              |
| GET     | /parents/reservations                             | Liste reservations         |
| POST    | /parents/reservations                             | Nouvelle reservation       |
| GET     | /parents/reservations/:id                         | Detail reservation         |
| PATCH   | /parents/reservations/:id                         | Modifier reservation       |
| DELETE  | /parents/reservations/:id                         | Supprimer reservation      |
| PATCH   | /parents/reservations/:id/accept                  | Accepter devis             |
| PATCH   | /parents/reservations/:id/negotiate               | Negocier devis             |
| PATCH   | /parents/reservations/:id/reject                  | Rejeter devis              |
| POST    | /parents/reservations/:rid/tutoring_requests      | Ajouter demande de tutorat |
| PATCH   | /parents/reservations/:rid/tutoring_requests/:id  | Modifier demande           |
| DELETE  | /parents/reservations/:rid/tutoring_requests/:id  | Supprimer demande          |
| GET     | /parents/sessions                                 | Liste seances              |
| GET     | /parents/sessions/:id                             | Detail seance              |
| GET     | /parents/sessions/:id/details                     | Detail complet seance      |
| GET     | /parents/sessions/:sid/session_reports/:id        | Rapport de seance          |
| PATCH   | /parents/sessions/:sid/session_reports/:id        | Valider rapport            |
| GET     | /parents/payments                                 | Historique paiements       |
| GET     | /parents/payments/:id                             | Detail paiement            |
| POST    | /parents/payments/create_online                   | Paiement en ligne          |
| GET     | /parents/payments/:id/check_status                | Statut paiement            |
| GET     | /parents/payments/:id/download_receipt            | Telecharger recu PDF       |
| GET     | /parents/reviews                                  | Liste avis                 |
| POST    | /parents/reviews                                  | Creer avis                 |
| GET     | /parents/reviews/:id                              | Detail avis                |
| PATCH   | /parents/reviews/:id                              | Modifier avis              |
| DELETE  | /parents/reviews/:id                              | Supprimer avis (archive)   |
| GET     | /parents/proposed_programs                        | Programmes proposes        |
| GET     | /parents/proposed_programs/:id                    | Detail programme           |
| GET     | /parents/invitations                              | Liste invitations          |
| POST    | /parents/invitations                              | Creer invitation           |
| GET     | /parents/invitations/:id                          | Detail invitation          |
| PATCH   | /parents/invitations/:id                          | Modifier invitation        |
| DELETE  | /parents/invitations/:id                          | Supprimer invitation       |

#### _Tuteur_

| Methode | Endpoint                                         | Description              |
| :------ | :----------------------------------------------- | :----------------------- |
| GET     | /tutors                                          | Dashboard                |
| GET     | /tutors/jobs                                     | Offres disponibles       |
| GET     | /tutors/jobs/:id                                 | Detail offre             |
| POST    | /tutors/candidacies                              | Postuler                 |
| GET     | /tutors/students/:id                             | Detail eleve             |
| GET     | /tutors/sessions                                 | Liste seances            |
| PATCH   | /tutors/sessions/:id                             | Modifier seance          |
| GET     | /tutors/sessions/:id/details                     | Detail seance            |
| GET     | /tutors/sessions/:sid/session_reports/:id        | Voir rapport             |
| POST    | /tutors/sessions/:sid/session_reports            | Soumettre rapport        |
| PATCH   | /tutors/sessions/:sid/session_reports/:id        | Modifier rapport         |
| GET     | /tutors/tutor_courses                            | Matieres enseignees      |
| POST    | /tutors/tutor_courses                            | Ajouter matiere/classe   |
| PATCH   | /tutors/tutor_courses/:id                        | Modifier                 |
| DELETE  | /tutors/tutor_courses/:id                        | Supprimer                |
| GET     | /tutors/tutoring_courses                         | Cours actifs             |
| POST    | /tutors/tutoring_courses/manage_schedules        | Gerer horaires           |
| GET     | /tutors/availabilities                           | Disponibilites           |
| POST    | /tutors/availabilities                           | Ajouter disponibilite    |
| PATCH   | /tutors/availabilities/:id                       | Modifier                 |
| DELETE  | /tutors/availabilities/:id                       | Supprimer                |
| POST    | /tutors/payment_informations                     | Ajouter methode paiement |
| PATCH   | /tutors/payment_informations/:id                 | Modifier                 |
| DELETE  | /tutors/payment_informations/:id                 | Supprimer                |
| PATCH   | /tutors/payment_informations/:id/mark_as_default | Defaut                   |
| GET     | /tutors/remunerations                            | Historique remunerations |
| GET     | /tutors/remunerations/:id/download_receipt       | Recu PDF                 |
| GET     | /tutors/descriptions                             | Bio                      |
| POST    | /tutors/descriptions                             | Creer bio                |
| PATCH   | /tutors/descriptions/:id                         | Modifier bio             |
| GET     | /tutors/works                                    | Experiences              |
| POST    | /tutors/works                                    | Ajouter experience       |
| PATCH   | /tutors/works/:id                                | Modifier                 |
| DELETE  | /tutors/works/:id                                | Supprimer                |
| GET     | /tutors/trainings                                | Formations               |
| POST    | /tutors/trainings                                | Ajouter formation        |
| PATCH   | /tutors/trainings/:id                            | Modifier                 |
| DELETE  | /tutors/trainings/:id                            | Supprimer                |
| GET     | /tutors/identities                               | Pieces d’identite        |
| POST    | /tutors/identities                               | Ajouter                  |
| PATCH   | /tutors/identities/:id                           | Modifier                 |
| DELETE  | /tutors/identities/:id                           | Supprimer                |

#### _Commun (authentifie)_

| Methode | Endpoint                               | Description          |
| :------ | :------------------------------------- | :------------------- |
| GET     | /common/notifications                  | Notifications        |
| GET     | /common/notifications/:id              | Detail               |
| DELETE  | /common/notifications/:id              | Supprimer            |
| PATCH   | /common/notifications/:id/mark_as_read | Marquer lu           |
| PATCH   | /common/notifications/mark_all_as_read | Tout marquer lu      |
| GET     | /common/notification_preferences       | Preferences          |
| PATCH   | /common/notification_preferences       | Modifier preferences |
| GET     | /common/contracts                      | Contrats             |
| GET     | /common/contracts/:id                  | Detail contrat       |
| PATCH   | /common/contracts/:id                  | Signer contrat       |
| GET     | /common/contracts/:cid/amendments/:id  | Avenant              |
| PATCH   | /common/contracts/:cid/amendments/:id  | Signer avenant       |
| GET     | /common/address                        | Adresse              |
| PATCH   | /common/address                        | Modifier adresse     |

#### _Webhook (serveur → serveur, non appele par le mobile)_

| Methode | Endpoint           | Description                   |
| :------ | :----------------- | :---------------------------- |
| POST    | /webhooks/notchpay | Callback de paiement NotchPay |

**Note :** Ce webhook est appele par NotchPay apres un paiement ou un transfert. Il ne concerne pas l’app mobile directement, mais le dev mobile doit savoir que le statut des paiements peut changer de maniere asynchrone (via polling check_status ou notification push).

**Evenements NotchPay geres :** | Evenement | Action | |———–|——–| | payment.complete | Le paiement du parent est confirme | | payment.failed | Le paiement du parent a echoue | | transfer.complete | La remuneration du tuteur est envoyee | | transfer.failed | Le transfert au tuteur a echoue |

### **7.7 Endpoints manquants (a prevoir en v2)**

Les donnees suivantes sont utilisees dans l’app web mais ne disposent **pas encore d’endpoint API** dedie. Le mobile devra les charger autrement ou les endpoints devront etre crees :

| Donnee                                 | Utilisation                                              | Solution temporaire                                          |
| :------------------------------------- | :------------------------------------------------------- | :----------------------------------------------------------- |
| **Liste des matieres (subjects)**      | Formulaire ajout matiere tuteur, selection matieres avis | Inclus dans les reponses existantes (tutor_courses, reviews) |
| **Liste des classes (school_classes)** | Formulaire ajout enfant (picker classe)                  | Inclus dans les reponses existantes (students)               |
| **Liste des villes (cities)**          | Formulaire adresse (autocomplete)                        | Utiliser Google Places API                                   |

**Recommandation :** Creer un namespace api/v1/references avec les endpoints GET /references/subjects, GET /references/school_classes, GET /references/cities pour que le mobile puisse charger ces listes de reference.

---

## **8\. Notifications push**

### **8.1 Integration OneSignal**

L’app utilise OneSignal pour les notifications push. A l’inscription de l’appareil :

**Endpoint :** POST /api/v1/user_devices

{  
 "user_device": {  
 "device_type": "ios",  
 "onesignal_player_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",  
 "device_name": "iPhone 15 Pro",  
 "device_model": "iPhone15,3",  
 "os_version": "18.0",  
 "app_version": "1.0.0",  
 "push_enabled": **true**  
 }  
}

### **8.2 Categories de notifications**

| Categorie    | Declencheur                                      | Cible            |
| :----------- | :----------------------------------------------- | :--------------- |
| reservation  | Nouvelle reservation, devis propose, acceptation | Parent           |
| sessions     | Seance planifiee, modifiee, rapport soumis       | Parent \+ Tuteur |
| payment      | Paiement recu, en attente                        | Parent           |
| remuneration | Remuneration disponible, payee                   | Tuteur           |
| contract     | Nouveau contrat, avenant                         | Parent \+ Tuteur |
| student      | Nouveau eleve ajoute                             | Parent           |
| job          | Nouvelle offre correspondant au profil           | Tuteur           |

### **8.3 Activite appareil**

Pour maintenir les tokens push a jour :

**Endpoint :** PATCH /api/v1/user_devices/activity

{ "onesignal_player_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" }

Appeler a chaque lancement de l’app ou mise au premier plan.

---

## **9\. Assets Store (App Store & Google Play)**

### **9.1 Informations de l’application**

| Champ              | Valeur                         |
| :----------------- | :----------------------------- |
| **Nom**            | SOE \- Solution of Education   |
| **Sous-titre**     | Tutorat a domicile au Cameroun |
| **Categorie**      | Education                      |
| **Sous-categorie** | Education                      |
| **Classification** | 4+ (tout public)               |
| **Langues**        | Francais (principal), Anglais  |

### **9.2 Description (App Store & Google Play)**

**Description courte (80 caracteres) :** \> Trouvez des tuteurs qualifies pour le soutien scolaire a domicile.

**Description longue :** \> SOE (Solution of Education) est la plateforme de reference pour le tutorat a domicile au Cameroun. Connectez-vous avec des tuteurs certifies pour un accompagnement scolaire personnalise de vos enfants. \> \> POUR LES PARENTS : \> \- Inscrivez vos enfants et definissez leurs besoins scolaires \> \- Demandez des devis personnalises pour du tutorat a domicile \> \- Suivez les seances en temps reel et validez les rapports \> \- Payez facilement via Mobile Money (MTN MoMo, Orange Money) \> \- Notez et evaluez vos tuteurs \> \> POUR LES TUTEURS : \> \- Completez votre profil professionnel (formations, experiences, matieres) \> \- Postulez aux offres de tutorat dans votre zone \> \- Gerez vos seances et soumettez vos rapports \> \- Recevez vos remunerations directement sur votre compte \> \> FONCTIONNALITES CLES : \> \- Paiement securise via Mobile Money \> \- Notifications en temps reel \> \- Emploi du temps integre \> \- Contrats electroniques avec signature \> \- Suivi complet des seances et rapports \> \- Systeme d’avis et de notation des tuteurs

### **9.3 Visuels a produire par le designer**

#### _Screenshots iPhone (6.7” \- iPhone 15 Pro Max)_

Le designer doit produire **6 a 10 screenshots** au format **1290 x 2796 px** :

| \#  | Ecran                 | Texte d’accroche                      |
| :-- | :-------------------- | :------------------------------------ |
| 1   | Dashboard Parent      | “Suivez l’education de vos enfants”   |
| 2   | Liste des enfants     | “Gerez les profils de vos enfants”    |
| 3   | Nouvelle reservation  | “Demandez un tuteur en quelques taps” |
| 4   | Paiement Mobile Money | “Payez facilement via Mobile Money”   |
| 5   | Liste des seances     | “Suivez toutes les seances en detail” |
| 6   | Avis tuteur (etoiles) | “Evaluez vos tuteurs”                 |
| 7   | Dashboard Tuteur      | “Gerez vos cours facilement”          |
| 8   | Profil tuteur complet | “Presentez votre expertise”           |
| 9   | Rapport de seance     | “Soumettez vos rapports en un clic”   |
| 10  | Notifications         | “Restez informe en temps reel”        |

**Style des screenshots :** \- Fond de couleur \#EAF0F9 ou gradient subtil \- Device mockup iPhone avec ecran de l’app \- Texte d’accroche au-dessus ou en dessous en Poppins Bold \- Couleur primaire \#FFB000 pour les accents \- Coherence avec la charte graphique

#### _Screenshots iPad (12.9”)_

**4 a 6 screenshots** au format **2048 x 2732 px** : \- Memes ecrans que iPhone mais adaptes a la mise en page tablette \- Montrer les layouts en split-view si pertinent

#### _Screenshots Android Phone_

**6 a 10 screenshots** au format **1080 x 1920 px** (minimum) : \- Memes ecrans avec mockup Android

#### _Screenshots Android Tablet (10”)_

**4 a 6 screenshots** au format **1920 x 1200 px** : \- Memes ecrans adaptes tablette

### **9.4 Icone de l’application**

| Element    | Specification                                   |
| :--------- | :---------------------------------------------- |
| **Format** | 1024 x 1024 px (PNG, sans alpha pour iOS)       |
| **Fond**   | \#035E7B (bleu-vert secondaire)                 |
| **Logo**   | Logo SOE blanc centre                           |
| **Rayon**  | iOS applique automatiquement les coins arrondis |
| **Style**  | Simple, lisible meme en petit (29x29px)         |

### **9.5 Feature Graphic (Google Play)**

| Element     | Specification                                            |
| :---------- | :------------------------------------------------------- |
| **Format**  | 1024 x 500 px                                            |
| **Fond**    | Gradient \#035E7B → \#010814                             |
| **Contenu** | Logo SOE \+ tagline \+ illustration parent-enfant-tuteur |
| **Texte**   | “Tutorat a domicile au Cameroun” en Poppins Bold blanc   |

### **9.6 Splash Screen / Launch Screen**

| Element       | Specification                  |
| :------------ | :----------------------------- |
| **Fond**      | \#FCFDFF (blanc casse)         |
| **Centre**    | Logo SOE (app_logo.svg)        |
| **Animation** | Fade-in subtil du logo (300ms) |

### **9.7 Onboarding (3 ecrans)**

| \#  | Illustration       | Titre                     | Description                                                             |
| :-- | :----------------- | :------------------------ | :---------------------------------------------------------------------- |
| 1   | Parent avec enfant | “Trouvez le tuteur ideal” | “Des tuteurs certifies pour un accompagnement personnalise a domicile.” |
| 2   | Calendrier/seances | “Suivez chaque seance”    | “Consultez les rapports, validez les seances et suivez la progression.” |
| 3   | Mobile Money       | “Payez en toute securite” | “Reglez vos seances facilement via MTN MoMo ou Orange Money.”           |

**Design :** \- Illustration centree (style flat/moderne, couleurs de la charte) \- Titre en Poppins Bold \#010814 \- Description en Poppins Regular \#526684 \- Indicateur de pagination (3 points, actif en \#FFB000) \- Bouton “Suivant” (primaire) / “Passer” (ghost) \- Dernier ecran : “Commencer” → ecran de connexion

---

## **10\. Exigences techniques**

### **10.1 Plateformes cibles**

| Plateforme  | Version minimum      | Ecrans                                 |
| :---------- | :------------------- | :------------------------------------- |
| **iOS**     | iOS 16+              | iPhone 8 et superieur, iPad (10e gen+) |
| **Android** | Android 10 (API 29)+ | 360dp largeur minimum, tablettes 10”+  |

### **10.2 Stockage local**

| Donnee                  | Stockage                                              |
| :---------------------- | :---------------------------------------------------- |
| JWT Token               | Keychain (iOS) / EncryptedSharedPreferences (Android) |
| Preferences utilisateur | UserDefaults / SharedPreferences                      |
| Cache images            | Disque (TTL 7 jours)                                  |
| Brouillons formulaire   | Base locale (optionnel)                               |

### **10.3 Gestion du reseau**

- Indicateur de connexion (banniere offline)

- Retry automatique sur echec reseau (3 tentatives, backoff exponentiel)

- Cache des donnees consultees recemment

- Pull-to-refresh sur toutes les listes

### **10.4 Securite**

- Certificat SSL pinning (optionnel mais recommande)

- Pas de stockage de mot de passe en clair

- Token JWT stocke de maniere securisee

- Biometrie (Face ID / Touch ID / Fingerprint) pour le login rapide (optionnel v2)

### **10.5 Performance**

- Temps de chargement ecran \< 2 secondes

- Taille APK/IPA \< 50 MB

- Images optimisees (WebP sur Android, HEIF sur iOS)

- Pagination sur toutes les listes (25 elements par page par defaut)

- Skeleton loading pendant le chargement

### **10.6 Accessibilite**

- Support VoiceOver (iOS) et TalkBack (Android)

- Tailles de texte dynamiques

- Contraste minimum 4.5:1 (WCAG AA)

- Labels sur tous les elements interactifs

---

## **11\. Annexes**

### **11.1 Statuts et leurs couleurs (badges)**

#### _Reservation_

| Statut        | Couleur fond | Couleur texte |
| :------------ | :----------- | :------------ |
| pending       | \#FFB000 20% | \#FF7A00      |
| active        | \#028226 20% | \#028226      |
| all_completed | \#035E7B 20% | \#035E7B      |
| all_cancelled | \#FF3F3F 20% | \#FF3F3F      |
| all_on_hold   | \#A3BCE2 20% | \#526684      |

#### _Devis (Quote)_

| Statut         | Couleur fond | Couleur texte |
| :------------- | :----------- | :------------ |
| draft          | \#A3BCE2 20% | \#526684      |
| proposed_price | \#FFB000 20% | \#FF7A00      |
| accepted       | \#028226 20% | \#028226      |
| rejected       | \#FF3F3F 20% | \#FF3F3F      |
| negotiation    | \#035E7B 20% | \#035E7B      |

#### _Seance_

| Statut    | Couleur fond | Couleur texte |
| :-------- | :----------- | :------------ |
| pending   | \#FFB000 20% | \#FF7A00      |
| completed | \#035E7B 20% | \#035E7B      |
| approved  | \#028226 20% | \#028226      |
| rejected  | \#FF3F3F 20% | \#FF3F3F      |

#### _Paiement_

| Statut     | Couleur fond | Couleur texte |
| :--------- | :----------- | :------------ |
| pending    | \#FFB000 20% | \#FF7A00      |
| processing | \#035E7B 20% | \#035E7B      |
| completed  | \#028226 20% | \#028226      |
| failed     | \#FF3F3F 20% | \#FF3F3F      |

### **11.2 Diagramme de flux \- Reservation**

Parent cree reservation (status: pending, quote: draft)  
 |  
 v  
Admin assigne tuteur \+ definit prix  
 |  
 v  
Quote passe a "proposed_price" (montant \> 0\)  
 |  
 \+----\> Parent ACCEPTE \--\> quote: accepted  
 | |  
 | v  
 | Parent PAIE \--\> reservation: active  
 | |  
 | v  
 | Seances creees automatiquement  
 | |  
 | v  
 | Tuteur enseigne \+ soumet rapport  
 | |  
 | v  
 | Parent valide rapport \--\> seance: approved  
 | |  
 | v  
 | Admin cree remuneration \--\> tuteur paye  
 |  
 \+----\> Parent NEGOCIE \--\> quote: negotiation  
 | |  
 | v  
 | Admin repropose \--\> quote: proposed_price (cycle)  
 |  
 \+----\> Parent REJETTE \--\> quote: rejected

### **11.3 Diagramme de flux \- Seance**

Seance creee (status: pending)  
 |  
 v  
Tuteur donne le cours  
 |  
 v  
Tuteur soumet rapport (signature \+ contenu)  
 |  
 v  
Seance passe a "completed"  
 |  
 \+----\> Admin/Parent VALIDE \--\> seance: approved  
 | |  
 | v  
 | Seance comptee pour remuneration  
 |  
 \+----\> Admin/Parent REJETTE \--\> seance: rejected  
 |  
 v  
 Tuteur doit resoumettre

### **11.4 Methodes de paiement supportees**

| Methode               | Code API      | Logo a prevoir |
| :-------------------- | :------------ | :------------- |
| **MTN MoMo**          | cm.mtn        | Logo MTN jaune |
| **Orange Money**      | cm.orange     | Logo Orange    |
| **Virement bancaire** | bank_transfer | Icone banque   |
| **Especes**           | cash          | Icone billets  |

### **11.5 Valeurs d’enum completes (reference API)**

#### _Utilisateur_

| Champ    | Valeurs possibles                        |
| :------- | :--------------------------------------- |
| role     | parent, tutor, simple_admin, super_admin |
| civility | Mr, Mme                                  |
| status   | active, inactive                         |
| lang     | fr, en                                   |

#### _Eleve (Student)_

| Champ     | Valeurs possibles         |
| :-------- | :------------------------ |
| gender    | male, feminine            |
| education | general, technic, primary |
| section   | francophone, anglophone   |

#### _Reservation_

| Champ        | Valeurs possibles                                          |
| :----------- | :--------------------------------------------------------- |
| status       | pending, active, all_completed, all_cancelled, all_on_hold |
| quote_status | draft, proposed_price, accepted, rejected, negotiation     |

#### _Demande de tutorat (TutoringRequest)_

| Champ                  | Valeurs possibles                                                   |
| :--------------------- | :------------------------------------------------------------------ |
| status                 | pending, tutor_assigned, in_progress, on_hold, completed, cancelled |
| preferred_tutor_gender | male, female, no_preference                                         |

#### _Seance (Session)_

| Champ  | Valeurs possibles                      |
| :----- | :------------------------------------- |
| status | pending, completed, approved, rejected |

#### _Paiement (Payment)_

| Champ          | Valeurs possibles                            |
| :------------- | :------------------------------------------- |
| status         | pending, processing, completed, failed       |
| payment_method | orange_money, mtn_money, bank_transfer, cash |
| payment_source | manual, online                               |

#### _Remuneration_

| Champ           | Valeurs possibles                                                       |
| :-------------- | :---------------------------------------------------------------------- |
| status          | pending_payment, paid                                                   |
| transfer_status | pending, processing, completed, failed                                  |
| payment_method  | manual, notchpay, orange_money, mtn_money, bank_transfer, cash, deposit |

#### _Contrat (Contract)_

Les contrats utilisent des champs de signature (fichier joint) et de statut de signature.

#### _Piece d’identite (Identity)_

| Champ         | Valeurs possibles       |
| :------------ | :---------------------- |
| document_type | cni, receipt, passeport |

#### _Avis (Review)_

| Champ  | Valeurs possibles        |
| :----- | :----------------------- |
| status | active, archived, hidden |
| rating | 1, 2, 3, 4, 5 (entier)   |

#### _Notification_

| Champ  | Valeurs possibles |
| :----- | :---------------- |
| status | read, unread      |

#### _Invitation_

| Champ              | Valeurs possibles        |
| :----------------- | :----------------------- |
| civility           | Mr, Mme                  |
| link_with_children | father, mother, guardian |
| lang               | fr, en                   |

#### _Signalement (Report)_

| Champ  | Valeurs possibles                          |
| :----- | :----------------------------------------- |
| status | pending, under_review, resolved, dismissed |

#### _Offre d’emploi (Job)_

| Champ  | Valeurs possibles   |
| :----- | :------------------ |
| status | published, archived |

### **11.6 Specifications d’upload de fichiers**

#### _Formats et tailles acceptes_

| Modele            | Champ     | Type             | Taille max   | Formats acceptes |
| :---------------- | :-------- | :--------------- | :----------- | :--------------- |
| **User**          | photo     | Image unique     | 5 MB         | PNG, JPG, JPEG   |
| **Student**       | photo     | Image unique     | 5 MB         | PNG, JPG, JPEG   |
| **Identity**      | images    | Images multiples | 5 MB/fichier | PNG, JPG, JPEG   |
| **Contract**      | signature | Image unique     | 5 MB         | PNG, JPG, JPEG   |
| **Amendment**     | signature | Image unique     | 5 MB         | PNG, JPG, JPEG   |
| **SessionReport** | signature | Image unique     | 5 MB         | PNG, JPG, JPEG   |

#### _Envoi des fichiers_

Tous les uploads de fichiers doivent utiliser le format multipart/form-data.

**Exemple : Upload photo de profil**

PATCH /api/v1/current_user  
Content-Type: multipart/form-data

user\[photo\] \= \<fichier binaire\>

**Exemple : Upload pieces d’identite (multiples)**

POST /api/v1/tutors/identities  
Content-Type: multipart/form-data

identity\[document_type\] \= cni  
identity\[birthday\] \= 1990-05-15  
identity\[expiration_date\] \= 2030-05-15  
identity\[images\]\[\] \= \<fichier 1\>  
identity\[images\]\[\] \= \<fichier 2\>

**Exemple : Upload signature rapport de seance**

POST /api/v1/tutors/sessions/:id/session_reports  
Content-Type: multipart/form-data

session_report\[date\] \= 2026-05-15  
session_report\[start_at\] \= 14:00  
session_report\[end_at\] \= 16:00  
session_report\[proceedings\] \= Texte du rapport...  
session_report\[signature\] \= \<fichier image de la signature\>

#### _Gestion cote mobile_

- **Compression** : Compresser les images avant upload (qualite 80%, max 1920px de large)

- **Camera** : Permettre la prise de photo directe ou le choix dans la galerie

- **Signature** : Canvas tactile → export en PNG transparent → upload comme fichier

- **Progress** : Afficher une barre de progression pendant l’upload

- **Retry** : En cas d’echec reseau, proposer de reessayer l’upload

### **11.7 References design et documentation**

- **Documentation API (Swagger)** : https://api.jeteste.site/api-docs (reference interactive des endpoints)

- **Web app en production** : https://app.jeteste.site (source de verite pour le design)

- **Landing page** : https://jeteste.site (pour le branding general)

- **Couleurs Tailwind** : Fichier tailwind.config.js du projet

- **Icones SVG** : Repertoire app/javascript/images/ du projet

---

_Document genere le 20 avril 2026 \- Version 1.1_ _Pour toute question technique sur l’API, contacter l’equipe backend._

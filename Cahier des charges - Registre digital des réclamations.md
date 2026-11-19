# Cahier des charges -Registre digital des réclamations

Moyens généraux · Sep 30, 2026 · @Demnna

## 1. Contexte et objectifs

L'application remplace le registre papier des réclamations « moyens généraux » par un outil web et mobile, avec un suivi par statut et un historique complet de chaque demande.

Aujourd'hui, un registre est posé chez le vigile de chaque bâtiment. Les responsables de classe y notent les incidents constatés dans les salles et espaces communs : climatisation, mobilier, éclairage, équipements. Ce fonctionnement pose quatre problèmes :

- le service des moyens généraux n'a aucune vision en temps réel et doit passer dans chaque bâtiment pour relever les registres ;
- le déclarant ne sait pas si sa demande a été vue, prise en charge ou résolue ;
- les signalements sont souvent incomplets (numéro de salle ou programme absent), ce qui ralentit l'intervention ;
- aucune statistique n'est possible sur les délais ou les salles à problèmes récurrents.

Objectifs :

1. Centraliser tous les signalements dans une base unique, consultable par le service des moyens généraux.
2. Rendre obligatoires la salle, le programme, le type de problème et la description.
3. Suivre chaque demande de l'ouverture à la résolution, avec un historique horodaté et nominatif.
4. Mesurer les délais de traitement et repérer les salles et équipements qui reviennent le plus souvent.

## 2. Périmètre et acteurs

Quatre rôles utilisent l'application ; seuls les moyens généraux et l'administrateur font avancer les demandes.

| Rôle | Qui | Signaler | Voit | Change le statut | Gère les référentiels |
| --- | --- | --- | --- | --- | --- |
| Délégué | Responsable de classe | Oui | Ses propres signalements | Non | Non |
| Vigile | Agent de sécurité, rattaché à un bâtiment | Oui, dans son bâtiment | Les salles de son bâtiment | Non | Non |
| Moyens généraux | Service chargé des interventions | Oui | Tout | Oui | Non (v1), oui (v2) |
| Administrateur | Responsable de l'application | Oui | Tout | Oui | Oui |

Dans le périmètre : les salles de cours et espaces communs de tous les bâtiments, pour tous les programmes.

Hors périmètre : la gestion des stocks de matériel, les bons de commande, la facturation des prestataires et les demandes informatiques liées aux comptes utilisateurs.

## 3. Fonctionnalités de la version 1 (livrée)

La v1 couvre le cycle complet d'une réclamation : connexion, signalement, consultation, traitement et historique. Elle fonctionne sur Android, iOS et navigateur web.

| Code | Fonctionnalité | Description | Rôles |
| --- | --- | --- | --- |
| F1 | Connexion | Email et mot de passe, session conservée sur l'appareil, déconnexion automatique à l'expiration | Tous |
| F2 | Signalement | Formulaire : bâtiment, salle, programme, type de problème, priorité, description (5 à 1 000 caractères) | Tous |
| F3 | Liste des réclamations | Triée de la plus récente à la plus ancienne, filtre par statut, actualisation par glissement | Tous, selon leur visibilité |
| F4 | Détail | Référence (REC-00001), description, salle, programme, priorité, déclarant, date, statut | Tous, selon leur visibilité |
| F5 | Changement de statut | Passage d'un statut à l'autre avec commentaire facultatif (500 caractères maximum) | Moyens généraux, administrateur |
| F6 | Historique | Chaque changement enregistre l'ancien statut, le nouveau, l'auteur, la date et le commentaire | Tous, selon leur visibilité |
| F7 | Documentation de l'API | Interface Swagger accessible sur `/api/docs` | Équipe technique |

Les référentiels (bâtiments, salles, programmes) et les comptes sont aujourd'hui créés par un script d'initialisation. Leur gestion depuis l'application est prévue en v1.1.

## 4. Règles de gestion

Une réclamation suit un cycle de quatre statuts. Seuls les moyens généraux et l'administrateur la font avancer, et chaque passage est historisé.

&#91;embedded content: cycle de vie d'une réclamation · 4 statuts\]

Toute autre transition est refusée par l'API. Un commentaire facultatif (500 caractères maximum) peut accompagner chaque passage.

### Visibilité

- Délégué : uniquement ses propres signalements.
- Vigile : toutes les réclamations des salles de son bâtiment ; il ne peut signaler que dans ce bâtiment.
- Moyens généraux et administrateur : toutes les réclamations.

Ces règles sont appliquées par le serveur, pas seulement masquées dans l'interface.

### Contenu d'un signalement

- Champs obligatoires : salle (et donc bâtiment), programme, type de problème, description de 5 à 1 000 caractères.
- Types de problème : Climatisation, Mobilier, Éclairage, Électricité, Équipement, Plomberie, Propreté, Autre.
- Priorités : Basse, Normale (par défaut), Haute, Urgente.
- Référence : numéro unique au format REC-00001, attribué à la création.

## 5. Évolutions prévues

Les évolutions sont regroupées en trois lots : v1.1 rend l'outil autonome, v2 facilite le travail sur le terrain, v3 donne des outils de pilotage. Chaque lot peut être mis en production seul.

### Lot v1.1 : autonomie de l'administration

| Code | Évolution | Description | Critères d'acceptation |
| --- | --- | --- | --- |
| E1 | Gestion des référentiels | Créer, modifier et archiver bâtiments, salles et programmes depuis l'application | Un administrateur ajoute une salle, elle apparaît aussitôt dans le formulaire ; une salle archivée disparaît du formulaire mais reste visible dans l'historique |
| E2 | Gestion des comptes | Créer un compte, choisir son rôle et son bâtiment, le désactiver | Un compte désactivé ne peut plus se connecter ; ses signalements restent consultables |
| E3 | Mot de passe | Changement du mot de passe par l'utilisateur, réinitialisation par lien envoyé par email | Le lien expire après une utilisation ou un délai fixé ; l'ancien mot de passe ne fonctionne plus |
| E4 | Recherche et pagination | Recherche par référence, salle ou mot de la description ; chargement progressif de la liste | La liste reste fluide au-delà de 1 000 réclamations ; une recherche par « REC-00042 » renvoie la bonne demande |

### Lot v2 : terrain

| Code | Évolution | Description | Critères d'acceptation |
| --- | --- | --- | --- |
| E5 | QR code par salle | Un QR code imprimé et collé dans chaque salle ouvre le formulaire avec le bâtiment et la salle déjà remplis | L'administrateur génère un PDF imprimable de tous les QR codes ; le scan pré-remplit la salle en moins de 3 secondes |
| E6 | Photos | Jusqu'à 3 photos par signalement, compressées sur le téléphone avant l'envoi | Les photos s'affichent dans le détail ; une photo de plus de 10 Mo est refusée avec un message clair |
| E7 | Notifications | Notification au service quand une réclamation est créée ; au déclarant quand son statut change | Un changement de statut déclenche une notification au déclarant ; chaque utilisateur peut couper les notifications non urgentes |
| E8 | Assignation | Les moyens généraux attribuent une réclamation à un technicien ou à un prestataire ; nouveau rôle Technicien | Le technicien ne voit que ce qui lui est assigné et peut passer une demande en Résolue avec un commentaire |
| E9 | Tableau de bord | Réclamations par statut, bâtiment et catégorie ; délai moyen de résolution ; salles les plus signalées ; export Excel | Les chiffres du tableau de bord correspondent à la liste filtrée sur la même période |
| E10 | Détection des doublons | Avant l'envoi, l'application signale une réclamation déjà ouverte pour la même salle et le même type de problème | Le déclarant voit la demande existante et choisit de la suivre au lieu d'en créer une nouvelle |

### Lot v3 : pilotage et qualité de service

| Code | Évolution | Description | Critères d'acceptation |
| --- | --- | --- | --- |
| E11 | Délais cibles par priorité | Un délai de prise en charge et de résolution est fixé pour chaque priorité ; alerte au responsable en cas de dépassement | Une réclamation urgente non prise en charge dans son délai apparaît en alerte sur le tableau de bord |
| E12 | Confirmation du déclarant | Après une résolution, le déclarant confirme ou rouvre la demande avec un commentaire | Sans réponse après un délai fixé, la résolution est confirmée automatiquement |
| E13 | Mode hors ligne | Un signalement saisi sans réseau est conservé sur le téléphone et envoyé au retour de la connexion | Aucun signalement n'est perdu après une coupure réseau pendant la saisie |
| E14 | Maintenance préventive | Planification d'interventions récurrentes (entretien des climatiseurs, contrôle électrique) qui créent des tâches automatiquement | Une intervention planifiée génère sa tâche à la date prévue et apparaît dans l'historique de la salle |
| E15 | Historique par salle | Fiche de chaque salle avec toutes ses réclamations et interventions | Depuis une salle, on retrouve toutes ses réclamations triées par date |

Les délais cibles de E11 et E12 restent à fixer avec le service des moyens généraux.

## 6. Exigences non fonctionnelles

L'application doit rester simple à utiliser sur un téléphone d'entrée de gamme et protéger les données des utilisateurs.

| Domaine | Exigence |
| --- | --- |
| Sécurité | HTTPS obligatoire en production ; mots de passe hachés (bcrypt) ; jeton d'accès à durée limitée ; droits vérifiés côté serveur pour chaque requête ; CORS limité au domaine de l'application |
| Protection contre les abus | Limitation du nombre de tentatives de connexion ; limitation du nombre de requêtes par utilisateur |
| Données personnelles | Seuls le nom, l'email et le rôle sont collectés ; conformité à la loi sénégalaise n° 2008-12 et déclaration du traitement à la CDP ; durée de conservation à fixer |
| Performance | Liste et détail affichés en moins de 2 secondes sur une connexion 3G ; photos compressées avant l'envoi |
| Disponibilité | Service accessible pendant les heures d'ouverture de l'établissement ; sauvegarde quotidienne de la base, conservée 30 jours ; restauration testée une fois par trimestre |
| Compatibilité | Android 7 et plus, iOS 15 et plus, dernières versions de Chrome, Firefox, Safari et Edge |
| Ergonomie | Un signalement complet en moins d'une minute ; interface en français ; textes lisibles et boutons assez grands pour une utilisation debout |
| Traçabilité | Toute modification de statut est historisée et ne peut pas être supprimée ; journaux serveur conservés 90 jours |
| Maintenabilité | Code organisé par fonctionnalité ; tests automatisés sur les règles de gestion ; documentation de l'API tenue à jour ; déploiement reproductible (Docker) |

## 7. Architecture technique et données

Une API NestJS unique sert l'application mobile et la version web ; toutes les règles de gestion et de droits sont appliquées par l'API.

&#91;embedded content: architecture · 2 clients, 1 API, 1 base ; en pointillés, les briques prévues en v2\]

Les briques en pointillés arrivent avec le lot v2. Le reste est en place.

| Couche | Technologie | Rôle |
| --- | --- | --- |
| Mobile et web | Flutter, GetX, Dio | Interface, navigation protégée par rôle, stockage sécurisé du jeton |
| API | NestJS, class-validator, Passport JWT | Validation des données, authentification, contrôle des rôles, règles de statut |
| Accès aux données | Prisma | Schéma, migrations versionnées, requêtes typées |
| Base de données | PostgreSQL | Stockage des utilisateurs, référentiels, réclamations et historique |
| Déploiement | Docker | Environnements de test et de production identiques |

### Modèle de données

| Entité | Champs principaux | Relations |
| --- | --- | --- |
| Utilisateur | nom, email, mot de passe haché, rôle | Rattaché à un bâtiment (vigile) ; auteur de réclamations et d'événements |
| Bâtiment | nom (unique) | Contient des salles |
| Salle | numéro (unique dans le bâtiment) | Appartient à un bâtiment ; reçoit des réclamations |
| Programme | nom (unique) | Concerné par des réclamations |
| Réclamation | numéro, type, priorité, statut, description, dates de création et de résolution | Une salle, un programme, un déclarant, plusieurs événements |
| Événement | ancien statut, nouveau statut, commentaire, date | Une réclamation, un auteur |

## 8. Planning et estimation de charge

L'ensemble représente environ 78 jours de développement, soit environ 18 semaines, pilote compris, pour un développeur à plein temps. Aucune date de démarrage n'est encore fixée.

&#91;embedded content: feuille de route · 1 pilote, 3 lots, 3 validations\]

Chaque losange est une condition à remplir avant de lancer le lot suivant.

| Lot | Contenu | Charge estimée | Durée calendaire |
| --- | --- | --- | --- |
| Pilote v1 | Déploiement, prise en main, suivi du pilote | 3 jours | 2 semaines |
| v1.1 | E1 référentiels (5 j), E2 comptes (4 j), E3 mot de passe (3 j), E4 recherche (3 j) | 15 jours | environ 3 semaines |
| v2 | E5 QR codes (4 j), E6 photos (6 j), E7 notifications (6 j), E8 assignation (7 j), E9 tableau de bord (8 j), E10 doublons (3 j) | 34 jours | environ 7 semaines |
| v3 | E11 délais cibles (5 j), E12 confirmation (3 j), E13 hors ligne (8 j), E14 maintenance préventive (7 j), E15 fiche salle (3 j) | 26 jours | environ 6 semaines |

Ces charges sont des estimations à affiner au début de chaque lot. L'ordre des évolutions à l'intérieur d'un lot peut changer selon les priorités du service.

## 9. Recette, indicateurs, livrables et risques

Chaque lot est validé par le service des moyens généraux sur un environnement de test, puis piloté dans un seul bâtiment avant d'être étendu.

### Recette

1. Tests automatisés : règles de visibilité par rôle et transitions de statut autorisées ou refusées.
2. Recette fonctionnelle : un scénario complet par rôle (délégué, vigile, moyens généraux, administrateur) sur l'environnement de test.
3. Pilote : un bâtiment pendant deux semaines, registre papier et application en parallèle.
4. Validation : procès-verbal signé par le responsable des moyens généraux, puis ouverture à tous les bâtiments.

### Indicateurs de réussite

| Indicateur | Mesure | Cible |
| --- | --- | --- |
| Adoption | Part des signalements faits dans l'application plutôt que sur papier | 100 % trois mois après le lancement, registre papier retiré |
| Qualité des signalements | Part des signalements avec salle et programme renseignés | 100 % (champs obligatoires) |
| Prise en charge | Délai moyen entre l'ouverture et le passage en cours | À fixer avec le service |
| Résolution | Délai moyen entre l'ouverture et la résolution, par priorité | À fixer avec le service |
| Qualité d'intervention | Part des réclamations rouvertes après résolution | En baisse d'un trimestre à l'autre |

### Livrables

- Code source de l'API et de l'application, dans un dépôt git avec README.
- Application Android (APK ou Play Store), iOS et version web.
- API déployée avec sa documentation Swagger.
- Guide d'utilisation d'une page par rôle.
- Session de prise en main pour les vigiles, les délégués et le service des moyens généraux.

### Hypothèses et risques

| Risque | Impact | Parade |
| --- | --- | --- |
| Les délégués continuent d'utiliser le registre papier | Données incomplètes, double travail | Communication aux responsables de classe, QR codes dans les salles, date de retrait du papier annoncée |
| Réseau faible dans certaines salles | Signalements abandonnés | Formulaire léger, mode hors ligne en v3 |
| Liste des salles et programmes incomplète au lancement | Signalements impossibles pour certaines salles | Inventaire validé par les moyens généraux avant le pilote |
| Comptes partagés entre plusieurs personnes | Historique non fiable | Un compte nominatif par personne |
| Pas de responsable technique après la mise en production | Pannes et sauvegardes non suivies | Désigner un référent technique et une procédure de sauvegarde |

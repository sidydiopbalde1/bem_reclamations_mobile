# Redesign Mobile -Registre des Réclamations BEM Dakar

**Date :** 2026-09-30  
**Statut :** Approuvé  
**Scope :** Visuel + UX (layouts repensés)  
**Approche :** "Command Center" (structure) + "Bold BEM Identity" (visuel)

---

## 1. Design System

### Palette de couleurs
| Rôle | Valeur | Usage |
|------|--------|-------|
| Primary | `#CC0000` (rouge BEM) | AppBar, boutons primaires, accents forts |
| Primary Dark | `#990000` | États pressed/hover |
| Primary Light | `#FFE5E5` | Fonds chips, badges légers |
| Surface | `#FFFFFF` | Fond des cards, écrans |
| Background | `#F5F5F5` | Fond général de l'app |
| On Surface | `#1A1A1A` | Texte principal |
| Secondary Text | `#666666` | Labels, sous-titres |
| Divider | `#E0E0E0` | Séparateurs |

### Couleurs sémantiques (statuts & priorités)
| Statut/Priorité | Couleur |
|-----------------|---------|
| OUVERTE | `#1565C0` (bleu) |
| EN_COURS | `#E65100` (orange) |
| RESOLUE | `#2E7D32` (vert) |
| REJETEE | `#757575` (gris) |
| Priorité BASSE | `#90A4AE` |
| Priorité NORMALE | `#42A5F5` |
| Priorité HAUTE | `#FFA726` |
| Priorité URGENTE | `#EF5350` |

### Typographie
- **Font principale :** `Inter` (ou Roboto si Inter indisponible)
- **Titre AppBar :** 20sp, SemiBold, blanc
- **Titre card :** 15sp, SemiBold, `#1A1A1A`
- **Sous-titre :** 13sp, Regular, `#666666`
- **Label chip :** 12sp, Medium
- **Bouton :** 14sp, SemiBold, tout en majuscule désactivé

### Forme & Espacements
- **Border radius cards :** 12dp
- **Border radius chips :** 20dp (pilule)
- **Border radius boutons :** 10dp
- **Padding cards :** 16dp
- **Elevation cards :** 2dp (ombre douce)
- **Espacement liste :** 8dp entre items

---

## 2. Écran Login

### Layout actuel
Formulaire simple centré, sans branding fort.

### Nouveau layout
- **Header BEM** : bandeau rouge `#CC0000` en haut (40% écran), logo BEM centré en blanc + tagline "Registre des Réclamations"
- **Card formulaire** : card blanche avec border-radius 20dp, légèrement chevauchant le bandeau rouge (overlap de 24dp)
- **Champs** : outlined avec focus rouge, icônes leading (email/lock)
- **Bouton connexion** : pleine largeur, rouge `#CC0000`, texte blanc, radius 10dp
- **Message d'erreur** : inline sous le formulaire en rouge clair

---

## 3. Écran Liste des Réclamations

### Layout actuel
Liste plate avec filtre statique.

### Nouveau layout

**AppBar**
- Fond rouge `#CC0000`
- Titre "Réclamations" en blanc
- Avatar/initiales utilisateur à droite (avec menu logout)

**Mini-dashboard (stats)**
- Row de 4 compteurs cliquables : Ouvertes / En cours / Résolues / Rejetées
- Chaque compteur : card blanche, chiffre en gras coloré selon statut, label sous
- Tapper un compteur applique le filtre correspondant

**Filter chips scrollables**
- Chips horizontaux: Toutes · Ouverte · En cours · Résolue · Rejetée
- Chip sélectionné : fond rouge `#CC0000`, texte blanc
- Chip non sélectionné : outlined gris

**Liste de réclamations**
- Card par réclamation avec :
  - Left-border colorée (4dp) selon priorité
  - Ligne 1 : `#N°XXX -Catégorie` (icône + nom) + badge statut (coin droit)
  - Ligne 2 : Bâtiment · Salle · Programme
  - Ligne 3 : Date + nom déclarant (grisé)
- FAB rouge "+" en bas à droite

**État vide**
- Illustration simple + message contextuel selon le filtre actif

---

## 4. Écran Formulaire (Nouvelle Réclamation)

### Layout actuel
Scroll unique avec tous les champs.

### Nouveau layout -Wizard 3 étapes

**Progress bar** : 3 steps avec indicateurs numérotés (cercles rouges/gris) en haut

**Étape 1 -Localisation**
- Dropdown Bâtiment (avec icône)
- Dropdown Salle (activé après bâtiment sélectionné, cascading)
- Dropdown Programme

**Étape 2 -Détail**
- Grille de catégories : 4 colonnes d'icônes tapables (Climatisation, Mobilier, Éclairage, etc.) avec label sous
- Sélecteur de priorité : 4 chips horizontaux colorés (Basse / Normale / Haute / Urgente)
- Champ Description : multiline, compteur de caractères (1000 max)

**Étape 3 -Confirmation**
- Récapitulatif en lecture seule des choix
- Bouton "Soumettre" rouge pleine largeur

**Navigation** : boutons Précédent / Suivant en bas, validation par étape

---

## 5. Écran Détail Réclamation

### Layout actuel
Infos et timeline en scroll linéaire.

### Nouveau layout

**Hero card**
- Header coloré dynamiquement selon statut (couleur de fond = couleur statut à 15% opacité)
- Numéro réclamation + badge statut en évidence
- Catégorie (icône large + label) + priorité badge

**Sections informations** (cards distinctes)
- Card "Localisation" : bâtiment, salle, programme
- Card "Déclarant" : nom, date de soumission
- Card "Description" : texte complet

**Timeline des événements**
- Ligne verticale rouge continue
- Chaque événement : cercle coloré selon statut (left) + date/heure + auteur + commentaire (right)
- Dernier événement mis en évidence (carte plus grande)

**Actions statut (ADMIN / MOYENS_GENERAUX)**
- Barre d'actions fixe en bas
- Bouton(s) d'action selon transitions valides
- Dialog de confirmation avec champ commentaire optionnel

---

## 6. Composants partagés à créer/refactoriser

| Composant | Description |
|-----------|-------------|
| `BemAppBar` | AppBar rouge avec titre blanc + actions contextuelles |
| `StatusChip` | Chip coloré selon statut (remplacement du widget actuel) |
| `PriorityBadge` | Badge coloré selon priorité |
| `ReclamationCard` | Card avec left-border colorée (remplace ReclamationTile) |
| `StatCounter` | Widget compteur cliquable pour le mini-dashboard |
| `StepIndicator` | Barre de progression wizard |
| `TimelineEvent` | Widget événement dans la timeline |
| `CategoryGrid` | Grille de sélection catégories avec icônes |
| `ConfirmActionDialog` | Dialog statut avec champ commentaire |

---

## 7. Fichiers impactés

```
lib/app/
├── core/
│   ├── theme/app_theme.dart          ← refonte complète palette + typography
│   └── widgets/                      ← nouveaux composants partagés
├── modules/
│   ├── auth/login/views/             ← nouveau layout login
│   ├── reclamations/
│   │   ├── list/views/               ← dashboard + chips + cards
│   │   ├── form/views/               ← wizard 3 étapes
│   │   └── detail/views/             ← hero card + timeline
│   └── widgets/                      ← ReclamationCard, StatusChip refonte
```

---

## 8. Dépendances Flutter à ajouter

| Package | Usage |
|---------|-------|
| `google_fonts` (optionnel) | Font Inter si disponible |

Aucune autre dépendance externe requise -tout le design utilise Flutter Material 3 natif.

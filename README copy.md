# Registre digital des réclamations – Moyens généraux

Remplace le registre papier tenu par les vigiles : chaque signalement (salle, programme,
type de problème, description) est enregistré, suivi par statut et historisé.


## Mobile (GetX)

```bash
cd mobile
flutter create . --platforms=android,ios   # génère les dossiers natifs
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

`10.0.2.2` pointe vers la machine hôte depuis l'émulateur Android ; sur un téléphone réel,
utilise l'IP locale de ta machine.

```
lib/
├── main.dart                 initialise les dépendances puis lance l'app
└── app/
    ├── core/                 config, thème, réseau (Dio + erreurs), stockage du token, utils, widgets communs
    ├── data/
    │   ├── models/           AppUser, Reclamation, référentiels, enums
    │   └── repositories/     accès API (aucune dépendance à GetX)
    ├── services/             AuthService (GetxService permanent, session courante)
    ├── di/                   dépendances globales (Dio, repositories, AuthService)
    ├── routes/               AppRoutes, AppPages, middlewares AuthGuard / GuestGuard
    └── modules/
        ├── auth/login/                   bindings · controllers · views
        └── reclamations/
            ├── list/ form/ detail/       bindings · controllers · views
            └── widgets/                  StatusChip, ReclamationTile, dialogue de statut
```

Principes :
- Les **repositories** ne connaissent pas GetX : ils restent testables et réutilisables.
- Chaque écran a son **Binding** qui injecte ses dépendances ; le contrôleur est détruit avec la page.
- Les écrans chargés depuis l'API utilisent `StateMixin` + `controller.obx(...)` (chargement / vide / erreur / données).
- Un 401 sur une requête authentifiée déconnecte automatiquement (session expirée).




  Cause racine : L'URL par défaut http://10.0.2.2:3000/api n'est valide que sur un émulateur Android. Tes devices disponibles sont Chrome (web) et Linux desktop -sur ces plateformes, 10.0.2.2 est        
  inaccessible.                               
                                                                                                                                                                                                            
  Fix : URL par défaut changée en http://localhost:3000/api.                                                                                                                                                
                                                                                                                                                                                                            
  Pour relancer l'app :                                                                                                                                                                                     
                                                                                                                                                                                                            
  # Web (Chrome)                                                                                                                                                                                            
  flutter run -d chrome                                                                                                                                                                                     
                                                            
  # Linux desktop                                                                                                                                                                                           
  flutter run -d linux                                                                                                                                                                                      
                                                                                                                                                                                                            
  Si tu testes sur d'autres plateformes plus tard :                                                                                                                                                         
                                                                                                                                                                                                            
  # Émulateur Android                                                                                                                                                                                       
  flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000/api                                                                                                                                
                                                                                                                                                                                                            
  # Appareil physique (remplace par l'IP de ta machine : 172.17.2.22)                                                                                                                                       
  flutter run --dart-define=API_BASE_URL=http://172.17.2.22:3000/api                                                                                                                                        
                                                                                                                                                                                                            
  Compte de test disponible : admin@bem.sn / Passw0rd!
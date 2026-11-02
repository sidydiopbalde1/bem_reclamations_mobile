# Mobile Redesign — BEM Dakar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refondre visuellement et fonctionnellement l'app Flutter de gestion des réclamations BEM Dakar avec une identité rouge/blanc, un mini-dashboard de stats, un formulaire wizard 3 étapes, et une timeline verticale sur le détail.

**Architecture:** Design system centralisé via `AppColors` + `AppTheme` + extensions visuelles. Chaque écran est refondu dans son propre fichier view sans toucher aux controllers (sauf liste et formulaire). Les nouveaux widgets partagés vivent dans `core/widgets/` et les widgets domaine dans `reclamations/widgets/`.

**Tech Stack:** Flutter 3.35+ / Dart 3.6+ · Material Design 3 · GetX 4.6 · aucune dépendance ajoutée

**Spec:** `docs/superpowers/specs/2026-09-30-redesign-mobile-design.md`

## Global Constraints

- Couleur primaire BEM : `Color(0xFFCC0000)` — ne jamais hardcoder ailleurs, toujours via `AppColors.primary`
- Pas de nouvelle dépendance pub : tout Material 3 natif Flutter
- Conserver toutes les interfaces publiques des controllers intactes (les vues lisent les mêmes observables)
- `ReclamationCard` remplace `ReclamationTile` — supprimer `reclamation_tile.dart` après remplacement de son import
- `flutter analyze` doit passer à 0 warning après chaque tâche

## Review Focus

- **Wizard step 0 vide** : si l'utilisateur est VIGILE avec un seul bâtiment auto-sélectionné, `nextStep()` doit passer sans erreur même si les dropdowns ont été pré-remplis programmatiquement
- **Stats compteur avec liste vide** : si `_cachedAll` est vide (premier chargement), `statusCounts` doit retourner des zéros proprement sans exception
- **Timeline event sans commentaire** : le widget `_TimelineItem` ne doit pas rendre une section commentaire quand `event.comment` est null ou vide
- **Hero card statut REJETEE** : la couleur `AppColors.statusRejetee` (`0xFF757575`) sur fond blanc donne peu de contraste — le fond du hero est `color.withValues(alpha: 0.10)` soit gris très clair, acceptable mais à vérifier visuellement
- **Overflow catégorie dans la grille** : les labels de catégorie (ex: "Climatisation") sont longs pour une cellule de 4 colonnes — `maxLines: 1` + `overflow: TextOverflow.ellipsis` est requis

---

## Task 1: Design System

**Files:**
- Create: `lib/app/core/theme/app_colors.dart`
- Modify: `lib/app/core/theme/app_theme.dart`
- Modify: `lib/app/modules/reclamations/widgets/reclamation_visuals.dart`

**Interfaces:**
- Produces:
  - `AppColors.primary` → `Color(0xFFCC0000)`
  - `AppColors.primaryDark` → `Color(0xFF990000)`
  - `AppColors.primaryLight` → `Color(0xFFFFE5E5)`
  - `AppColors.background` → `Color(0xFFF5F5F5)`
  - `AppColors.surface` → `Color(0xFFFFFFFF)`
  - `AppColors.onSurface` → `Color(0xFF1A1A1A)`
  - `AppColors.secondaryText` → `Color(0xFF666666)`
  - `AppColors.divider` → `Color(0xFFE0E0E0)`
  - `AppColors.statusOuverte` → `Color(0xFF1565C0)`
  - `AppColors.statusEnCours` → `Color(0xFFE65100)`
  - `AppColors.statusResolue` → `Color(0xFF2E7D32)`
  - `AppColors.statusRejetee` → `Color(0xFF757575)`
  - `AppColors.priorityBasse` → `Color(0xFF90A4AE)`
  - `AppColors.priorityNormale` → `Color(0xFF42A5F5)`
  - `AppColors.priorityHaute` → `Color(0xFFFFA726)`
  - `AppColors.priorityUrgente` → `Color(0xFFEF5350)`
  - `ReclamationStatusVisuals.color` (updated) — uses `AppColors.status*`
  - `ReclamationPriorityVisuals.color` — **new extension**, uses `AppColors.priority*`

- [ ] **Step 1: Créer `app_colors.dart`**

```dart
// lib/app/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand BEM Dakar
  static const primary = Color(0xFFCC0000);
  static const primaryDark = Color(0xFF990000);
  static const primaryLight = Color(0xFFFFE5E5);

  // Surfaces
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF666666);
  static const divider = Color(0xFFE0E0E0);

  // Statuts
  static const statusOuverte = Color(0xFF1565C0);
  static const statusEnCours = Color(0xFFE65100);
  static const statusResolue = Color(0xFF2E7D32);
  static const statusRejetee = Color(0xFF757575);

  // Priorités
  static const priorityBasse = Color(0xFF90A4AE);
  static const priorityNormale = Color(0xFF42A5F5);
  static const priorityHaute = Color(0xFFFFA726);
  static const priorityUrgente = Color(0xFFEF5350);
}
```

- [ ] **Step 2: Réécrire `app_theme.dart`**

```dart
// lib/app/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: AppColors.surface,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    chipTheme: const ChipThemeData(shape: StadiumBorder()),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
  );
}
```

- [ ] **Step 3: Mettre à jour `reclamation_visuals.dart` — status colors + nouvelle extension priority**

```dart
// lib/app/modules/reclamations/widgets/reclamation_visuals.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/reclamation_enums.dart';

extension ReclamationStatusVisuals on ReclamationStatus {
  Color get color => switch (this) {
        ReclamationStatus.ouverte => AppColors.statusOuverte,
        ReclamationStatus.enCours => AppColors.statusEnCours,
        ReclamationStatus.resolue => AppColors.statusResolue,
        ReclamationStatus.rejetee => AppColors.statusRejetee,
      };

  String get actionLabel => switch (this) {
        ReclamationStatus.ouverte => 'Rouvrir',
        ReclamationStatus.enCours => 'Mettre en cours',
        ReclamationStatus.resolue => 'Marquer résolue',
        ReclamationStatus.rejetee => 'Rejeter',
      };
}

extension ReclamationPriorityVisuals on ReclamationPriority {
  Color get color => switch (this) {
        ReclamationPriority.basse => AppColors.priorityBasse,
        ReclamationPriority.normale => AppColors.priorityNormale,
        ReclamationPriority.haute => AppColors.priorityHaute,
        ReclamationPriority.urgente => AppColors.priorityUrgente,
      };
}

extension ReclamationCategoryVisuals on ReclamationCategory {
  IconData get icon => switch (this) {
        ReclamationCategory.climatisation => Icons.ac_unit,
        ReclamationCategory.mobilier => Icons.chair_outlined,
        ReclamationCategory.eclairage => Icons.lightbulb_outline,
        ReclamationCategory.electricite => Icons.electrical_services,
        ReclamationCategory.equipement => Icons.devices_other,
        ReclamationCategory.plomberie => Icons.plumbing,
        ReclamationCategory.proprete => Icons.cleaning_services_outlined,
        ReclamationCategory.autre => Icons.help_outline,
      };
}
```

- [ ] **Step 4: Vérifier**

```bash
cd /home/sidydiopbalde/Téléchargements/reclamations/mobile
flutter analyze lib/app/core/theme/ lib/app/modules/reclamations/widgets/reclamation_visuals.dart
```
Résultat attendu : `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/core/theme/app_colors.dart lib/app/core/theme/app_theme.dart lib/app/modules/reclamations/widgets/reclamation_visuals.dart
git commit -m "feat: design system BEM rouge/blanc — AppColors, AppTheme Material3, priority colors"
```

---

## Task 2: Widgets partagés — PriorityBadge + StatusChip refonte

**Files:**
- Create: `lib/app/modules/reclamations/widgets/priority_badge.dart`
- Modify: `lib/app/modules/reclamations/widgets/status_chip.dart`

**Interfaces:**
- Consumes: `ReclamationPriorityVisuals.color` (Task 1), `AppColors` (Task 1)
- Produces:
  - `PriorityBadge({required ReclamationPriority priority})` — badge coloré selon priorité
  - `StatusChip({required ReclamationStatus status})` — inchangé en signature, restyled

- [ ] **Step 1: Créer `priority_badge.dart`**

```dart
// lib/app/modules/reclamations/widgets/priority_badge.dart
import 'package:flutter/material.dart';

import '../../../data/models/reclamation_enums.dart';
import 'reclamation_visuals.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final ReclamationPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Mettre à jour `status_chip.dart` — arrondi 20dp + couleur via AppColors**

```dart
// lib/app/modules/reclamations/widgets/status_chip.dart
import 'package:flutter/material.dart';

import '../../../data/models/reclamation_enums.dart';
import 'reclamation_visuals.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ReclamationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Vérifier**

```bash
flutter analyze lib/app/modules/reclamations/widgets/priority_badge.dart lib/app/modules/reclamations/widgets/status_chip.dart
```
Résultat attendu : `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app/modules/reclamations/widgets/priority_badge.dart lib/app/modules/reclamations/widgets/status_chip.dart
git commit -m "feat: PriorityBadge widget + StatusChip restyled arrondi 20dp"
```

---

## Task 3: ReclamationCard (remplace ReclamationTile)

**Files:**
- Create: `lib/app/modules/reclamations/widgets/reclamation_card.dart`
- Modify: `lib/app/modules/reclamations/list/views/reclamation_list_view.dart` (import + usage)
- Delete: `lib/app/modules/reclamations/widgets/reclamation_tile.dart`

**Interfaces:**
- Consumes: `AppColors`, `ReclamationPriorityVisuals.color`, `ReclamationCategoryVisuals.icon`, `StatusChip`, `AppDateFormat`, `Reclamation`
- Produces: `ReclamationCard({required Reclamation reclamation, required VoidCallback onTap})`

- [ ] **Step 1: Créer `reclamation_card.dart`**

```dart
// lib/app/modules/reclamations/widgets/reclamation_card.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_format.dart';
import '../../../data/models/reclamation.dart';
import 'reclamation_visuals.dart';
import 'status_chip.dart';

class ReclamationCard extends StatelessWidget {
  const ReclamationCard({
    super.key,
    required this.reclamation,
    required this.onTap,
  });

  final Reclamation reclamation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre gauche colorée par priorité
              Container(width: 4, color: reclamation.priority.color),
              // Contenu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            reclamation.category.icon,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${reclamation.reference} · ${reclamation.category.label}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(status: reclamation.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reclamation.location,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${AppDateFormat.dateTime(reclamation.createdAt)} · ${reclamation.reportedByName}',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Mettre à jour `reclamation_list_view.dart` — remplacer l'import et l'usage**

Dans `lib/app/modules/reclamations/list/views/reclamation_list_view.dart` :
- Remplacer la ligne `import '../../widgets/reclamation_tile.dart';`
  par `import '../../widgets/reclamation_card.dart';`
- Dans `_ReclamationList.build`, remplacer `ReclamationTile(` par `ReclamationCard(`

- [ ] **Step 3: Supprimer `reclamation_tile.dart`**

```bash
rm /home/sidydiopbalde/Téléchargements/reclamations/mobile/lib/app/modules/reclamations/widgets/reclamation_tile.dart
```

- [ ] **Step 4: Vérifier**

```bash
flutter analyze lib/app/modules/reclamations/
```
Résultat attendu : `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/modules/reclamations/widgets/reclamation_card.dart lib/app/modules/reclamations/list/views/reclamation_list_view.dart
git rm lib/app/modules/reclamations/widgets/reclamation_tile.dart
git commit -m "feat: ReclamationCard avec left-border priorité — remplace ReclamationTile"
```

---

## Task 4: Écran Login redesign

**Files:**
- Modify: `lib/app/modules/auth/login/views/login_view.dart`

**Interfaces:**
- Consumes: `AppColors`, `LoginController` (inchangé — `formKey`, `emailController`, `passwordController`, `errorMessage`, `isSubmitting`, `submit`)
- Review Focus (wizard step 0 vide) : test de confirmation que `errorMessage` null n'affiche rien

- [ ] **Step 1: Réécrire `login_view.dart`**

```dart
// lib/app/modules/auth/login/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Column(
            children: [
              // Bandeau rouge BEM
              Container(
                height: screenHeight * 0.40,
                width: double.infinity,
                color: AppColors.primary,
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 72, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'BEM Dakar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Registre des Réclamations',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Card formulaire chevauchant le bandeau
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 6,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Connexion',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: controller.passwordController,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: Validators.required,
                              onFieldSubmitted: (_) => controller.submit(),
                            ),
                            Obx(() {
                              final message = controller.errorMessage.value;
                              if (message == null) return const SizedBox(height: 16);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  message,
                                  style: const TextStyle(color: AppColors.primary),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }),
                            Obx(
                              () => FilledButton(
                                onPressed: controller.isSubmitting.value ? null : controller.submit,
                                child: controller.isSubmitting.value
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Se connecter'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Vérifier**

```bash
flutter analyze lib/app/modules/auth/
```
Résultat attendu : `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/modules/auth/login/views/login_view.dart
git commit -m "feat: login redesign — bandeau rouge BEM + card formulaire chevauchante"
```

---

## Task 5: Écran Liste — mini-dashboard stats + filter chips + FAB

**Files:**
- Modify: `lib/app/modules/reclamations/list/controllers/reclamation_list_controller.dart`
- Create: `lib/app/core/widgets/stat_counter.dart`
- Modify: `lib/app/modules/reclamations/list/views/reclamation_list_view.dart`

**Interfaces:**
- Consumes: `AppColors`, `ReclamationCard` (Task 3), `ReclamationStatusVisuals.color`
- Produces (controller additions):
  - `Map<ReclamationStatus, int> get statusCounts` — counts calculés depuis `_cachedAll`

- [ ] **Step 1: Mettre à jour `reclamation_list_controller.dart` — ajouter cache stats**

```dart
// lib/app/modules/reclamations/list/controllers/reclamation_list_controller.dart
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';

class ReclamationListController extends GetxController with StateMixin<List<Reclamation>> {
  ReclamationListController(this._repository, this._authService);

  final ReclamationRepository _repository;
  final AuthService _authService;

  final statusFilter = Rxn<ReclamationStatus>();
  late final Worker _filterWorker;

  // Cache pour les stats — mis à jour uniquement lors du fetch sans filtre
  var _cachedAll = <Reclamation>[];

  Map<ReclamationStatus, int> get statusCounts => {
        for (final s in ReclamationStatus.values)
          s: _cachedAll.where((r) => r.status == s).length,
      };

  @override
  void onInit() {
    super.onInit();
    _filterWorker = ever(statusFilter, (_) => fetch());
    fetch();
  }

  Future<void> fetch({bool showLoader = true}) async {
    if (showLoader) change(null, status: RxStatus.loading());

    try {
      final items = await _repository.fetchAll(status: statusFilter.value);
      // Met à jour le cache stats seulement quand on charge sans filtre
      if (statusFilter.value == null) _cachedAll = List.unmodifiable(items);
      change(items, status: items.isEmpty ? RxStatus.empty() : RxStatus.success());
    } on ApiException catch (error) {
      change(null, status: RxStatus.error(error.message));
    }
  }

  void filterBy(ReclamationStatus? status) => statusFilter.value = status;

  Future<void> openNewReclamation() async {
    final created = await Get.toNamed<bool>(AppRoutes.newReclamation);
    if (created ?? false) await fetch(showLoader: false);
  }

  Future<void> openDetail(String id) async {
    await Get.toNamed(AppRoutes.reclamationDetail(id));
    await fetch(showLoader: false);
  }

  Future<void> logout() => _authService.logout();

  @override
  void onClose() {
    _filterWorker.dispose();
    super.onClose();
  }
}
```

- [ ] **Step 2: Créer `stat_counter.dart`**

```dart
// lib/app/core/widgets/stat_counter.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatCounter extends StatelessWidget {
  const StatCounter({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  final int count;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Réécrire `reclamation_list_view.dart`**

```dart
// lib/app/modules/reclamations/list/views/reclamation_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/stat_counter.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../widgets/reclamation_card.dart';
import '../../widgets/reclamation_visuals.dart';
import '../controllers/reclamation_list_controller.dart';

class ReclamationListView extends GetView<ReclamationListController> {
  const ReclamationListView({super.key});

  Future<void> _refresh() => controller.fetch(showLoader: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _StatsDashboard(controller: controller),
          _StatusFilterBar(controller: controller),
          Expanded(
            child: controller.obx(
              (items) => RefreshIndicator(
                onRefresh: _refresh,
                child: _ReclamationList(items: items!),
              ),
              onLoading: const LoadingView(),
              onEmpty: RefreshIndicator(
                onRefresh: _refresh,
                child: const _EmptyState(),
              ),
              onError: (message) => ErrorView(
                message: message ?? 'Erreur',
                onRetry: controller.fetch,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openNewReclamation,
        icon: const Icon(Icons.add),
        label: const Text('Signaler'),
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.controller});

  final ReclamationListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = controller.statusCounts;
      final selectedFilter = controller.statusFilter.value;
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: Row(
          children: [
            for (final status in ReclamationStatus.values)
              StatCounter(
                count: counts[status] ?? 0,
                label: status.label,
                color: status.color,
                isSelected: selectedFilter == status,
                onTap: () => controller.filterBy(
                  selectedFilter == status ? null : status,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.controller});

  final ReclamationListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SizedBox(
        height: 52,
        child: Obx(() {
          final selected = controller.statusFilter.value;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _FilterChip(
                label: 'Toutes',
                isSelected: selected == null,
                color: AppColors.primary,
                onSelected: () => controller.filterBy(null),
              ),
              for (final status in ReclamationStatus.values)
                _FilterChip(
                  label: status.label,
                  isSelected: selected == status,
                  color: status.color,
                  onSelected: () => controller.filterBy(status),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: color.withValues(alpha: 0.15),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.secondaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? color : AppColors.divider),
        backgroundColor: AppColors.surface,
        showCheckmark: false,
      ),
    );
  }
}

class _ReclamationList extends GetView<ReclamationListController> {
  const _ReclamationList({required this.items});

  final List<Reclamation> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final reclamation = items[index];
        return ReclamationCard(
          reclamation: reclamation,
          onTap: () => controller.openDetail(reclamation.id),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 64, color: AppColors.secondaryText),
        SizedBox(height: 12),
        Text(
          'Aucune réclamation',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Vérifier**

```bash
flutter analyze lib/app/modules/reclamations/list/ lib/app/core/widgets/stat_counter.dart
```
Résultat attendu : `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/modules/reclamations/list/controllers/reclamation_list_controller.dart \
        lib/app/core/widgets/stat_counter.dart \
        lib/app/modules/reclamations/list/views/reclamation_list_view.dart
git commit -m "feat: liste — mini-dashboard stats, filter chips restyled, ReclamationCard"
```

---

## Task 6: Formulaire wizard 3 étapes

**Files:**
- Modify: `lib/app/modules/reclamations/form/controllers/reclamation_form_controller.dart`
- Create: `lib/app/core/widgets/step_indicator.dart`
- Modify: `lib/app/modules/reclamations/form/views/reclamation_form_view.dart`

**Interfaces:**
- Consumes: `AppColors`, `ReclamationFormData`, `ReclamationCategoryVisuals.icon`
- Produces (controller additions):
  - `final currentStep = 0.obs` — étape courante (0, 1, 2)
  - `final pageController = PageController()` — pour `PageView`
  - `final step0FormKey = GlobalKey<FormState>()` — validation étape 0
  - `final step1FormKey = GlobalKey<FormState>()` — validation étape 1
  - `bool nextStep()` — valide, avance, retourne false si invalide
  - `void previousStep()` — revient en arrière

- [ ] **Step 1: Mettre à jour `reclamation_form_controller.dart` — ajouter gestion wizard**

```dart
// lib/app/modules/reclamations/form/controllers/reclamation_form_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/new_reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/models/referentials.dart';
import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../data/repositories/referentials_repository.dart';
import '../../../../services/auth_service.dart';

typedef ReclamationFormData = ({List<Building> buildings, List<Program> programs});

class ReclamationFormController extends GetxController with StateMixin<ReclamationFormData> {
  ReclamationFormController(this._referentials, this._reclamations, this._authService);

  final ReferentialsRepository _referentials;
  final ReclamationRepository _reclamations;
  final AuthService _authService;

  // Wizard
  final currentStep = 0.obs;
  final pageController = PageController();

  // Form keys par étape
  final step0FormKey = GlobalKey<FormState>();
  final step1FormKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();

  final selectedBuilding = Rxn<Building>();
  final selectedRoom = Rxn<Room>();
  final selectedProgram = Rxn<Program>();
  final selectedCategory = Rxn<ReclamationCategory>();
  final priority = ReclamationPriority.normale.obs;
  final isSubmitting = false.obs;

  List<Room> get availableRooms => selectedBuilding.value?.rooms ?? const [];

  @override
  void onInit() {
    super.onInit();
    loadFormData();
  }

  Future<void> loadFormData() async {
    change(null, status: RxStatus.loading());

    try {
      final buildings = _restrictToUserBuilding(await _referentials.fetchBuildings());
      final programs = await _referentials.fetchPrograms();

      if (buildings.length == 1) selectedBuilding.value = buildings.single;
      change((buildings: buildings, programs: programs), status: RxStatus.success());
    } on ApiException catch (error) {
      change(null, status: RxStatus.error(error.message));
    }
  }

  void selectBuilding(Building? building) {
    selectedBuilding.value = building;
    selectedRoom.value = null;
  }

  /// Valide l'étape courante et avance si valide. Retourne false si validation échoue.
  bool nextStep() {
    // La grille de catégories n'est pas un FormField — vérification manuelle sur étape 1.
    if (currentStep.value == 1 && selectedCategory.value == null) {
      AppSnackbar.show('Veuillez sélectionner un type de problème');
      return false;
    }

    final GlobalKey<FormState>? key = switch (currentStep.value) {
      0 => step0FormKey,
      1 => step1FormKey,
      _ => null,
    };
    if (key != null && !(key.currentState?.validate() ?? false)) return false;

    currentStep.value++;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return true;
  }

  void previousStep() {
    currentStep.value--;
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> submit() async {
    isSubmitting.value = true;
    try {
      await _reclamations.create(
        NewReclamation(
          roomId: selectedRoom.value!.id,
          programId: selectedProgram.value!.id,
          category: selectedCategory.value!,
          priority: priority.value,
          description: descriptionController.text,
        ),
      );
      Get.back(result: true);
      AppSnackbar.show('Signalement enregistré');
    } on ApiException catch (error) {
      isSubmitting.value = false;
      AppSnackbar.show(error.message);
    }
  }

  List<Building> _restrictToUserBuilding(List<Building> buildings) {
    final restrictedId = _authService.currentUser.value?.restrictedBuildingId;
    if (restrictedId == null) return buildings;
    return buildings.where((building) => building.id == restrictedId).toList();
  }

  @override
  void onClose() {
    pageController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
```

- [ ] **Step 2: Créer `step_indicator.dart`**

```dart
// lib/app/core/widgets/step_indicator.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.labels,
  });

  final int totalSteps;
  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          _StepCircle(index: i, currentStep: currentStep, label: labels[i]),
          if (i < totalSteps - 1)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: i < currentStep ? AppColors.primary : AppColors.divider,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.currentStep,
    required this.label,
  });

  final int index;
  final int currentStep;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isActive ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isDone || isActive ? AppColors.primary : AppColors.divider,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.secondaryText,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          labels[index],
          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Réécrire `reclamation_form_view.dart`**

```dart
// lib/app/modules/reclamations/form/views/reclamation_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/models/referentials.dart';
import '../../widgets/reclamation_visuals.dart';
import '../controllers/reclamation_form_controller.dart';

class ReclamationFormView extends GetView<ReclamationFormController> {
  const ReclamationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau signalement')),
      body: controller.obx(
        (data) => _WizardBody(data: data!),
        onLoading: const LoadingView(),
        onError: (message) => ErrorView(
          message: message ?? 'Erreur',
          onRetry: controller.loadFormData,
        ),
      ),
    );
  }
}

class _WizardBody extends GetView<ReclamationFormController> {
  const _WizardBody({required this.data});

  final ReclamationFormData data;

  static const _stepLabels = ['Localisation', 'Détail', 'Confirmation'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Obx(
            () => StepIndicator(
              totalSteps: 3,
              currentStep: controller.currentStep.value,
              labels: _stepLabels,
            ),
          ),
        ),
        const Divider(height: 1),
        // Pages
        Expanded(
          child: PageView(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Step0Location(data: data),
              const _Step1Detail(),
              _Step2Confirmation(data: data),
            ],
          ),
        ),
        // Navigation buttons
        _WizardNavigation(data: data),
      ],
    );
  }
}

class _Step0Location extends GetView<ReclamationFormController> {
  const _Step0Location({required this.data});

  final ReclamationFormData data;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step0FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Où se trouve le problème ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<Building>(
            initialValue: controller.selectedBuilding.value,
            decoration: const InputDecoration(
              labelText: 'Bâtiment',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            items: [
              for (final b in data.buildings)
                DropdownMenuItem(value: b, child: Text(b.name)),
            ],
            onChanged: controller.selectBuilding,
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<Room>(
              key: ValueKey(controller.selectedBuilding.value?.id),
              initialValue: controller.selectedRoom.value,
              decoration: const InputDecoration(
                labelText: 'Numéro de salle',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              items: [
                for (final r in controller.availableRooms)
                  DropdownMenuItem(value: r, child: Text(r.number)),
              ],
              onChanged: (room) => controller.selectedRoom.value = room,
              validator: Validators.required,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Program>(
            initialValue: controller.selectedProgram.value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Programme',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: [
              for (final p in data.programs)
                DropdownMenuItem(value: p, child: Text(p.name)),
            ],
            onChanged: (p) => controller.selectedProgram.value = p,
            validator: Validators.required,
          ),
        ],
      ),
    );
  }
}

class _Step1Detail extends GetView<ReclamationFormController> {
  const _Step1Detail();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step1FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Quel est le problème ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Text('Type de problème', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _CategoryGrid(),
          const SizedBox(height: 20),
          Text('Priorité', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _PrioritySelector(),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.descriptionController,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Ex. : le climatiseur fait du bruit et ne refroidit plus',
              alignLabelWithHint: true,
            ),
            validator: Validators.minLength(5),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends GetView<ReclamationFormController> {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;
      return GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
        children: [
          for (final category in ReclamationCategory.values)
            _CategoryCell(
              category: category,
              isSelected: selected == category,
              onTap: () => controller.selectedCategory.value = category,
            ),
        ],
      );
    });
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ReclamationCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySelector extends GetView<ReclamationFormController> {
  const _PrioritySelector();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          for (final p in ReclamationPriority.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _PriorityChip(
                  priority: p,
                  isSelected: controller.priority.value == p,
                  onTap: () => controller.priority.value = p,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  final ReclamationPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          priority.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? color : AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Step2Confirmation extends GetView<ReclamationFormController> {
  const _Step2Confirmation({required this.data});

  final ReclamationFormData data;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final building = controller.selectedBuilding.value;
      final room = controller.selectedRoom.value;
      final program = controller.selectedProgram.value;
      final category = controller.selectedCategory.value;
      final prio = controller.priority.value;
      final desc = controller.descriptionController.text;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Récapitulatif',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _ConfirmRow(icon: Icons.business_outlined, label: 'Bâtiment', value: building?.name ?? '—'),
          _ConfirmRow(icon: Icons.meeting_room_outlined, label: 'Salle', value: room?.number ?? '—'),
          _ConfirmRow(icon: Icons.school_outlined, label: 'Programme', value: program?.name ?? '—'),
          if (category != null)
            _ConfirmRow(icon: category.icon, label: 'Catégorie', value: category.label),
          _ConfirmRow(icon: Icons.flag_outlined, label: 'Priorité', value: prio.label),
          const Divider(height: 24),
          Text('Description', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(desc.isEmpty ? '—' : desc),
          ),
        ],
      );
    });
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardNavigation extends GetView<ReclamationFormController> {
  const _WizardNavigation({required this.data});

  final ReclamationFormData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Obx(() {
        final step = controller.currentStep.value;
        final isLast = step == 2;
        final isFirst = step == 0;

        return Row(
          children: [
            if (!isFirst)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text('Précédent'),
                ),
              ),
            if (!isFirst) const SizedBox(width: 12),
            Expanded(
              flex: isFirst ? 1 : 1,
              child: isLast
                  ? Obx(
                      () => FilledButton.icon(
                        onPressed: controller.isSubmitting.value ? null : controller.submit,
                        icon: controller.isSubmitting.value
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Soumettre'),
                      ),
                    )
                  : FilledButton(
                      onPressed: () => controller.nextStep(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text('Suivant'),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
```

- [ ] **Step 4: Vérifier**

```bash
flutter analyze lib/app/modules/reclamations/form/ lib/app/core/widgets/step_indicator.dart
```
Résultat attendu : `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/app/modules/reclamations/form/controllers/reclamation_form_controller.dart \
        lib/app/core/widgets/step_indicator.dart \
        lib/app/modules/reclamations/form/views/reclamation_form_view.dart
git commit -m "feat: formulaire wizard 3 étapes — localisation, détail, confirmation"
```

---

## Task 7: Écran Détail — hero card + sections + timeline verticale

**Files:**
- Modify: `lib/app/modules/reclamations/detail/views/reclamation_detail_view.dart`

**Interfaces:**
- Consumes: `AppColors`, `StatusChip`, `PriorityBadge` (Task 2), `ReclamationStatusVisuals.color`, `ReclamationCategoryVisuals.icon`
- Review Focus : `_TimelineItem` sans commentaire, hero card statut REJETEE

- [ ] **Step 1: Réécrire `reclamation_detail_view.dart`**

```dart
// lib/app/modules/reclamations/detail/views/reclamation_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/reclamation_visuals.dart';
import '../../widgets/status_change_dialog.dart';
import '../../widgets/status_chip.dart';
import '../controllers/reclamation_detail_controller.dart';

class ReclamationDetailView extends GetView<ReclamationDetailController> {
  const ReclamationDetailView({super.key});

  static const _defaultTitle = Text('Réclamation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: controller.obx(
          (r) => Text(r!.reference),
          onLoading: _defaultTitle,
          onError: (_) => _defaultTitle,
        ),
      ),
      body: controller.obx(
        (r) => _ReclamationDetails(reclamation: r!),
        onLoading: const LoadingView(),
        onError: (message) => ErrorView(
          message: message ?? 'Erreur',
          onRetry: controller.fetch,
        ),
      ),
      bottomNavigationBar: controller.canManage
          ? controller.obx(
              (r) => _StatusActions(reclamation: r!),
              onLoading: const SizedBox.shrink(),
              onError: (_) => const SizedBox.shrink(),
            )
          : null,
    );
  }
}

class _ReclamationDetails extends StatelessWidget {
  const _ReclamationDetails({required this.reclamation});

  final Reclamation reclamation;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroCard(reclamation: reclamation),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(
                title: 'Localisation',
                icon: Icons.meeting_room_outlined,
                value: reclamation.location,
              ),
              const SizedBox(height: 8),
              _InfoCard(
                title: 'Programme',
                icon: Icons.school_outlined,
                value: reclamation.programName,
              ),
              const SizedBox(height: 8),
              _DeclarantCard(reclamation: reclamation),
              const SizedBox(height: 8),
              _DescriptionCard(description: reclamation.description),
              const SizedBox(height: 16),
              Text(
                'Historique',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _Timeline(events: reclamation.events.reversed.toList()),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.reclamation});

  final Reclamation reclamation;

  @override
  Widget build(BuildContext context) {
    final statusColor = reclamation.status.color;
    return Container(
      width: double.infinity,
      color: statusColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reclamation.reference,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              StatusChip(status: reclamation.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  reclamation.category.icon,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reclamation.category.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              PriorityBadge(priority: reclamation.priority),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.value,
  });

  final String title;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeclarantCard extends StatelessWidget {
  const _DeclarantCard({required this.reclamation});

  final Reclamation reclamation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Déclarant',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reclamation.reportedByName,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  AppDateFormat.dateTime(reclamation.createdAt),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Text(
                  'Description',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});

  final List<ReclamationEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          _TimelineItem(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});

  final ReclamationEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final title = event.isCreation
        ? 'Signalement créé'
        : '${event.fromStatus!.label} → ${event.toStatus.label}';
    final hasComment = event.comment != null && event.comment!.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne gauche : cercle + ligne
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: event.toStatus.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: event.toStatus.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: AppColors.divider),
                    ),
                  ),
              ],
            ),
          ),
          // Colonne droite : contenu
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 16),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.authorName} · ${AppDateFormat.dateTime(event.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      if (hasComment) ...[
                        const SizedBox(height: 6),
                        Text(
                          event.comment!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusActions extends GetView<ReclamationDetailController> {
  const _StatusActions({required this.reclamation});

  final Reclamation reclamation;

  Future<void> _onStatusPressed(ReclamationStatus target) async {
    final comment = await StatusChangeDialog.show(target);
    if (comment != null) await controller.changeStatus(target, comment);
  }

  @override
  Widget build(BuildContext context) {
    final nextStatuses = reclamation.status.nextStatuses;
    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(12),
        child: Obx(
          () => Row(
            children: [
              for (final status in nextStatuses)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.tonal(
                      onPressed:
                          controller.isUpdating.value ? null : () => _onStatusPressed(status),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: Text(status.actionLabel),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Vérifier l'ensemble du projet**

```bash
flutter analyze lib/
```
Résultat attendu : `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/app/modules/reclamations/detail/views/reclamation_detail_view.dart
git commit -m "feat: détail redesign — hero card dynamique, sections cards, timeline verticale"
```

---

## Vérification finale

- [ ] Lancer l'app en mode debug et parcourir les 4 écrans :
  ```bash
  flutter run
  ```
  - Login : bandeau rouge en haut, card blanche chevauchante, logo BEM
  - Liste : mini-dashboard 4 compteurs, filter chips, cards avec left-border colorée
  - Formulaire : wizard 3 étapes avec StepIndicator, grille catégories, confirmation
  - Détail : hero card colorée selon statut, sections cards, timeline avec cercles et ligne verticale

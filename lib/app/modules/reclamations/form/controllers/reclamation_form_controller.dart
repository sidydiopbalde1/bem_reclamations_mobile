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
      // Retour d'abord : Get.back() fermerait le snackbar au lieu de la page.
      Get.back(result: true);
      AppSnackbar.show('Signalement enregistré');
    } on ApiException catch (error) {
      isSubmitting.value = false;
      AppSnackbar.show(error.message);
    }
  }

  /// Un vigile ne peut signaler que dans son bâtiment.
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

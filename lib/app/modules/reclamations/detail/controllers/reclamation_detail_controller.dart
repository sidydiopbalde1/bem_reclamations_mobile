import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../services/auth_service.dart';

class ReclamationDetailController extends GetxController with StateMixin<Reclamation> {
  ReclamationDetailController({
    required this.reclamationId,
    required ReclamationRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  final String reclamationId;
  final ReclamationRepository _repository;
  final AuthService _authService;

  final isUpdating = false.obs;

  bool get canManage => _authService.currentUser.value?.role.canManageReclamations ?? false;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    change(null, status: RxStatus.loading());

    try {
      change(await _repository.fetchById(reclamationId), status: RxStatus.success());
    } on ApiException catch (error) {
      change(null, status: RxStatus.error(error.message));
    }
  }

  Future<void> changeStatus(ReclamationStatus target, String comment) async {
    isUpdating.value = true;

    try {
      final updated = await _repository.updateStatus(reclamationId, target, comment: comment);
      change(updated, status: RxStatus.success());
      AppSnackbar.show('Statut mis à jour : ${target.label}');
    } on ApiException catch (error) {
      AppSnackbar.show(error.message);
    } finally {
      isUpdating.value = false;
    }
  }
}

import 'package:get/get.dart';

import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../data/repositories/referentials_repository.dart';
import '../../../../services/auth_service.dart';
import '../controllers/reclamation_form_controller.dart';

class ReclamationFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReclamationFormController(
        Get.find<ReferentialsRepository>(),
        Get.find<ReclamationRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}

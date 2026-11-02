import 'package:get/get.dart';

import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../services/auth_service.dart';
import '../controllers/reclamation_list_controller.dart';

class ReclamationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReclamationListController(
        Get.find<ReclamationRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}

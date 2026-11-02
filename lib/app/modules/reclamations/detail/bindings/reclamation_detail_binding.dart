import 'package:get/get.dart';

import '../controllers/reclamation_detail_controller.dart';

class ReclamationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReclamationDetailController(
        reclamationId: Get.parameters['id']!,
        repository: Get.find(),
        authService: Get.find(),
      ),
    );
  }
}

import 'package:get/get.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/referentials_repository.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController(
          Get.find<ReferentialsRepository>(),
          Get.find<AdminRepository>(),
        ),);
  }
}

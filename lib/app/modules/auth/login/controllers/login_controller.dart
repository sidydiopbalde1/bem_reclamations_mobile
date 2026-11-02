import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';

class LoginController extends GetxController {
  LoginController(this._authService);

  final AuthService _authService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.reclamations);
    } on ApiException catch (error) {
      // Pas de reset en cas de succès : le contrôleur est détruit avec la page.
      isSubmitting.value = false;
      errorMessage.value = error.message;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/app_user.dart';
import '../../../services/auth_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._authService);
  final AuthService _authService;

  AppUser get user => _authService.currentUser.value!;

  final isSubmitting = false.obs;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    try {
      await _authService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      AppSnackbar.show('Mot de passe modifié');
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../routes/app_routes.dart';

/// Session utilisateur, disponible dans toute l'app (service permanent).
class AuthService extends GetxService {
  AuthService(this._repository);

  final AuthRepository _repository;
  final currentUser = Rxn<AppUser>();

  bool get isLoggedIn => currentUser.value != null;

  Future<AuthService> init() async {
    currentUser.value = await _repository.restoreSession();
    return this;
  }

  Future<void> login({required String email, required String password}) async {
    currentUser.value = await _repository.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
}

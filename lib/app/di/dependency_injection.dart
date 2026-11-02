import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../core/network/dio_factory.dart';
import '../core/storage/token_storage.dart';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/reclamation_repository.dart';
import '../data/repositories/referentials_repository.dart';
import '../services/auth_service.dart';

/// Dépendances globales. Les contrôleurs sont enregistrés par leurs Bindings.
abstract final class DependencyInjection {
  static Future<void> init() async {
    final tokenStorage = Get.put(const TokenStorage(FlutterSecureStorage()), permanent: true);
    final dio = Get.put(
      DioFactory.create(tokenStorage: tokenStorage, onUnauthorized: _onSessionExpired),
      permanent: true,
    );

    Get
      ..lazyPut(() => ReferentialsRepository(dio), fenix: true)
      ..lazyPut(() => ReclamationRepository(dio), fenix: true)
      ..lazyPut(() => AdminRepository(dio), fenix: true);

    final authService = AuthService(AuthRepository(dio, tokenStorage));
    await Get.putAsync(authService.init, permanent: true);
  }

  static void _onSessionExpired() {
    // Pendant la restauration de session, AuthService n'est pas encore enregistré.
    if (Get.isRegistered<AuthService>()) Get.find<AuthService>().logout();
  }
}

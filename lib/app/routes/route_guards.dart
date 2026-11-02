import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/models/app_user.dart';
import '../services/auth_service.dart';
import 'app_routes.dart';

/// Réservé aux utilisateurs connectés.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<AuthService>().isLoggedIn ? null : const RouteSettings(name: AppRoutes.login);
  }
}

/// Réservé aux visiteurs non connectés (écran de connexion).
class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<AuthService>().isLoggedIn ? const RouteSettings(name: AppRoutes.reclamations) : null;
  }
}

/// Réservé aux administrateurs.
class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final role = Get.find<AuthService>().currentUser.value?.role;
    return role == UserRole.admin ? null : const RouteSettings(name: AppRoutes.reclamations);
  }
}

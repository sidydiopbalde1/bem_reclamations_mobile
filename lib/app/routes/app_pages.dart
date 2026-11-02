import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/reclamations/detail/bindings/reclamation_detail_binding.dart';
import '../modules/reclamations/detail/views/reclamation_detail_view.dart';
import '../modules/reclamations/form/bindings/reclamation_form_binding.dart';
import '../modules/reclamations/form/views/reclamation_form_view.dart';
import '../modules/reclamations/list/bindings/reclamation_list_binding.dart';
import '../modules/reclamations/list/views/reclamation_list_view.dart';
import 'app_routes.dart';
import 'route_guards.dart';

abstract final class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.reclamations,
      page: () => const ReclamationListView(),
      binding: ReclamationListBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.newReclamation,
      page: () => const ReclamationFormView(),
      binding: ReclamationFormBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.reclamationDetailPattern,
      page: () => const ReclamationDetailView(),
      binding: ReclamationDetailBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminView(),
      binding: AdminBinding(),
      middlewares: [AuthGuard(), AdminGuard()],
    ),
  ];
}

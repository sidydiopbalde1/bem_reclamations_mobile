import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';

class RegistreApp extends StatelessWidget {
  const RegistreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Get.find<AuthService>().isLoggedIn;

    return GetMaterialApp(
      title: 'Registre des réclamations',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: isLoggedIn ? AppRoutes.reclamations : AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}

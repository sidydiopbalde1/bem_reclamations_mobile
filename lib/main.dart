import 'package:flutter/material.dart';

import 'app/di/dependency_injection.dart';
import 'app/registre_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const RegistreApp());
}

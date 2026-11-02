abstract final class Env {
  /// Valeur par défaut : localhost (web, Linux, iOS simulator).
  /// Android emulator : flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  /// Appareil physique : flutter run --dart-define=API_BASE_URL=http://IP_MACHINE:3000/api
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}

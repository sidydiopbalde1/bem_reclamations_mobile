import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';

abstract final class DioFactory {
  static const _unauthorized = 401;
  static const _authorizationHeader = 'Authorization';

  static Dio create({
    required TokenStorage tokenStorage,
    required void Function() onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.read();
          if (token != null) options.headers[_authorizationHeader] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) {
          // Un 401 sur une requête authentifiée = session expirée (pas un mauvais mot de passe).
          final wasAuthenticated = error.requestOptions.headers.containsKey(_authorizationHeader);
          if (error.response?.statusCode == _unauthorized && wasAuthenticated) onUnauthorized();
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}

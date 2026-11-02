import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/token_storage.dart';
import '../models/app_user.dart';

class AuthRepository {
  const AuthRepository(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<AppUser> login({required String email, required String password}) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final body = response.data!;
      await _tokenStorage.save(body['accessToken'] as String);
      return AppUser.fromJson(body['user'] as Map<String, dynamic>);
    });
  }

  /// Retourne l'utilisateur si un token valide est stocké, sinon `null`.
  Future<AppUser?> restoreSession() async {
    if (await _tokenStorage.read() == null) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return AppUser.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) await _tokenStorage.clear();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } catch (_) {
      // Échec silencieux : on déconnecte localement même si le serveur est injoignable.
    }
    await _tokenStorage.clear();
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return guardApiCall(() async {
      await _dio.patch<void>(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    });
  }
}

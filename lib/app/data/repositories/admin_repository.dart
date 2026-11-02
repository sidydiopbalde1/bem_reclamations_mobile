import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../models/app_user.dart';

class AdminRepository {
  const AdminRepository(this._dio);

  final Dio _dio;
  static const _path = '/users';

  Future<List<AppUser>> fetchUsers() => guardApiCall(() async {
        final res = await _dio.get<List<dynamic>>(_path);
        return res.data!.cast<Map<String, dynamic>>().map(AppUser.fromJson).toList();
      });

  Future<AppUser> createUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? buildingId,
  }) =>
      guardApiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          _path,
          data: {
            'fullName': fullName,
            'email': email,
            'password': password,
            'role': role.apiValue,
            if (buildingId != null) 'buildingId': buildingId,
          },
        );
        return AppUser.fromJson(res.data!);
      },);

  Future<AppUser> updateUser(String id, {UserRole? role, String? buildingId}) =>
      guardApiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '$_path/$id',
          data: {
            if (role != null) 'role': role.apiValue,
            'buildingId': buildingId,
          },
        );
        return AppUser.fromJson(res.data!);
      },);

  Future<void> deactivateUser(String id) => guardApiCall(() async {
        await _dio.patch<void>('$_path/$id/deactivate');
      });
}

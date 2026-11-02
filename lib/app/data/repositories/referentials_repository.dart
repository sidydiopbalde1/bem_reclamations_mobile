import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../models/referentials.dart';

class ReferentialsRepository {
  const ReferentialsRepository(this._dio);

  final Dio _dio;

  Future<List<Building>> fetchBuildings() => _fetchList('/buildings', Building.fromJson);

  Future<List<Program>> fetchPrograms() => _fetchList('/programs', Program.fromJson);

  Future<List<T>> _fetchList<T>(String path, T Function(Map<String, dynamic>) fromJson) {
    return guardApiCall(() async {
      final response = await _dio.get<List<dynamic>>(path);
      return response.data!.cast<Map<String, dynamic>>().map(fromJson).toList();
    });
  }

  // Buildings
  Future<Building> createBuilding(String name) => guardApiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/buildings', data: {'name': name});
        return Building.fromJson(res.data!);
      });

  Future<Building> updateBuilding(String id, String name) => guardApiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/buildings/$id', data: {'name': name});
        return Building.fromJson(res.data!);
      });

  Future<void> deleteBuilding(String id) => guardApiCall(() async {
        await _dio.delete<void>('/buildings/$id');
      });

  // Rooms
  Future<Room> createRoom(String buildingId, String number) => guardApiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/buildings/$buildingId/rooms',
          data: {'number': number},
        );
        return Room.fromJson(res.data!);
      });

  Future<Room> updateRoom(String id, String number) => guardApiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/rooms/$id', data: {'number': number});
        return Room.fromJson(res.data!);
      });

  Future<void> deleteRoom(String id) => guardApiCall(() async {
        await _dio.delete<void>('/rooms/$id');
      });

  // Programs
  Future<Program> createProgram(String name) => guardApiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/programs', data: {'name': name});
        return Program.fromJson(res.data!);
      });

  Future<Program> updateProgram(String id, String name) => guardApiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/programs/$id', data: {'name': name});
        return Program.fromJson(res.data!);
      });

  Future<void> deleteProgram(String id) => guardApiCall(() async {
        await _dio.delete<void>('/programs/$id');
      });
}

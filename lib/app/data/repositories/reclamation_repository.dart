import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../models/new_reclamation.dart';
import '../models/reclamation.dart';
import '../models/reclamation_enums.dart';

class ReclamationRepository {
  const ReclamationRepository(this._dio);

  final Dio _dio;
  static const _path = '/reclamations';
  static const _pageSize = 50;

  Future<List<Reclamation>> fetchAll({ReclamationStatus? status, String? search, int offset = 0}) {
    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        _path,
        queryParameters: {
          if (status != null) 'status': status.apiValue,
          'limit': _pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (offset > 0) 'offset': offset,
        },
      );
      final items = response.data!['items'] as List<dynamic>;
      return items.cast<Map<String, dynamic>>().map(Reclamation.fromJson).toList();
    });
  }

  Future<Reclamation> fetchById(String id) {
    return guardApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('$_path/$id');
      return Reclamation.fromJson(response.data!);
    });
  }

  Future<Reclamation> create(NewReclamation input) {
    return guardApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(_path, data: input.toJson());
      return Reclamation.fromJson(response.data!);
    });
  }

  Future<Reclamation> updateStatus(String id, ReclamationStatus status, {String? comment}) {
    return guardApiCall(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '$_path/$id/status',
        data: {
          'status': status.apiValue,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return Reclamation.fromJson(response.data!);
    });
  }
}

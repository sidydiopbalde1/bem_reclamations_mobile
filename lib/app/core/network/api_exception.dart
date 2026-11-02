import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    final serverMessage = data is Map ? data['message'] : null;

    final message = switch (serverMessage) {
      final String text => text,
      final List<dynamic> messages when messages.isNotEmpty => messages.first.toString(),
      _ => switch (error.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.connectionError =>
            'Impossible de joindre le serveur. Vérifiez votre connexion.',
          _ => 'Une erreur inattendue est survenue.',
        },
    };

    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}

/// Convertit les erreurs Dio en [ApiException] lisibles par l'UI.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw ApiException.fromDio(error);
  } catch (_) {
    throw const ApiException('Une erreur inattendue est survenue.');
  }
}

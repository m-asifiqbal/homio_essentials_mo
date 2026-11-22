import 'package:dio/dio.dart';

enum ApiErrorKind { offline, timeout, unauthorized, notFound, server, cancelled, unknown }

/// One error type for the whole app, mapped from Dio failures.
class ApiException implements Exception {
  const ApiException(this.kind, [this.message, this.statusCode]);
  final ApiErrorKind kind;
  final String? message;
  final int? statusCode;

  bool get isOffline => kind == ApiErrorKind.offline || kind == ApiErrorKind.timeout;

  factory ApiException.from(Object e) {
    if (e is ApiException) return e;
    if (e is DioException) {
      final code = e.response?.statusCode;
      final msg = e.response?.data is Map ? (e.response!.data['message'] ?? e.response!.data['hint'])?.toString() : e.message;
      return switch (e.type) {
        DioExceptionType.connectionError => ApiException(ApiErrorKind.offline, msg),
        DioExceptionType.connectionTimeout || DioExceptionType.receiveTimeout || DioExceptionType.sendTimeout => ApiException(ApiErrorKind.timeout, msg),
        DioExceptionType.badResponse when code == 401 || code == 403 => ApiException(ApiErrorKind.unauthorized, msg, code),
        DioExceptionType.badResponse when code == 404 => ApiException(ApiErrorKind.notFound, msg, code),
        DioExceptionType.badResponse => ApiException(ApiErrorKind.server, msg, code),
        DioExceptionType.cancel => ApiException(ApiErrorKind.cancelled, msg),
        _ => ApiException(ApiErrorKind.unknown, msg, code),
      };
    }
    return ApiException(ApiErrorKind.unknown, e.toString());
  }

  @override
  String toString() => 'ApiException(${kind.name}${statusCode == null ? '' : ' $statusCode'}: ${message ?? ''})';
}

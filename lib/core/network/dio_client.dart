import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:homio_essentials/core/config/env.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/utils/json.dart';

/// Dio configured for Supabase's REST API (PostgREST).
Dio buildDio() {
  final dio = Dio(BaseOptions(
    baseUrl: Env.restUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'apikey': Env.supabaseKey, 'Authorization': 'Bearer ${Env.supabaseKey}', 'Accept': 'application/json'},
    responseType: ResponseType.json,
  ));
  dio.interceptors.add(_RetryInterceptor(dio));
  if (kDebugMode) dio.interceptors.add(LogInterceptor(requestHeader: false, responseHeader: false, responseBody: false, logPrint: (o) => debugPrint('[dio] $o')));
  return dio;
}

/// Retries idempotent requests (GET, and read-only RPCs) after network hiccups: 0.6 s, then 1.8 s.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this.dio);
  final Dio dio;
  static const _delays = [Duration(milliseconds: 600), Duration(milliseconds: 1800)];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final o = err.requestOptions;
    final attempt = (o.extra['retry'] as int?) ?? 0;
    final retryable = (o.method == 'GET' || o.extra['idempotent'] == true) &&
        (err.type == DioExceptionType.connectionError || err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.receiveTimeout ||
            (err.response?.statusCode ?? 0) >= 500);
    if (!retryable || attempt >= _delays.length) return handler.next(err);
    await Future<void>.delayed(_delays[attempt]);
    o.extra['retry'] = attempt + 1;
    try {
      handler.resolve(await dio.fetch(o));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// Minimal PostgREST client on top of Dio: select (with paging), rpc, insert.
class PostgrestApi {
  PostgrestApi(this.dio);
  final Dio dio;

  Future<List<Json>> select(String table, {required String columns, Map<String, String> filters = const {}, List<String> order = const [], int? offset, int? limit}) async {
    try {
      final res = await dio.get<List<dynamic>>(table, queryParameters: {
        'select': columns,
        ...filters,
        if (order.isNotEmpty) 'order': order.join(','),
        if (offset != null) 'offset': '$offset',
        if (limit != null) 'limit': '$limit',
      });
      return (res.data ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  /// All rows, 1000 at a time, in a stable order (the order columns must form a unique key).
  Future<List<Json>> selectAll(String table, {required String columns, required List<String> order, Map<String, String> filters = const {}}) async {
    const page = 1000;
    final out = <Json>[];
    for (var offset = 0;; offset += page) {
      final batch = await select(table, columns: columns, filters: filters, order: order, offset: offset, limit: page);
      out.addAll(batch);
      if (batch.length < page) return out;
    }
  }

  Future<dynamic> rpc(String fn, {Map<String, dynamic> params = const {}, bool readOnly = true}) async {
    try {
      final res = await dio.post<dynamic>('rpc/$fn', data: params, options: Options(extra: {'idempotent': readOnly}));
      return res.data;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> insert(String table, Json row) async {
    try {
      await dio.post<dynamic>(table, data: row, options: Options(headers: {'Prefer': 'return=minimal'}));
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}

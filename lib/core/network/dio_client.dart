/// ============================================================
/// DIO CLIENT — the app's one HTTP stack (Supabase REST / PostgREST)
/// ============================================================
///
/// Layers, outermost first (MVVM + Riverpod):
///   View        widgets watch a ViewModel (a Riverpod `Notifier` with an immutable UiState)
///   ViewModel   calls a repository CONTRACT (`domain/repository`), never Dio
///   Repository  `data/repository` implements the contract over data sources
///   Data source [PostgrestApi] below — turns Dio failures into one typed [ApiException]
///   Dio         built here by [buildDio]; interceptors, in order:
///                 1. retry (GET / read-only RPC, twice, on connection errors, timeouts and 5xx)
///                 2. network-error report (after the retries gave up) → the connection ViewModel re-checks
///                 3. debug log
/// ============================================================
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:homio_essentials/core/config/env.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/utils/json.dart';

/// Dio configured for Supabase's REST API (PostgREST).
///
/// [baseUrl] defaults to the Supabase REST url from the build config (tests pass their own).
/// [retry] false → fail at once (used by the connection probe, which must answer quickly).
/// [onNetworkError] is called when a request ended in a network failure (no connection / timeout), after retries.
Dio buildDio({
  String? baseUrl,
  bool retry = true,
  Duration connectTimeout = const Duration(seconds: 12),
  Duration receiveTimeout = const Duration(seconds: 30),
  VoidCallback? onNetworkError,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? Env.restUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    headers: {'apikey': Env.supabaseKey, 'Authorization': 'Bearer ${Env.supabaseKey}', 'Accept': 'application/json'},
    responseType: ResponseType.json,
  ));
  if (retry) dio.interceptors.add(_RetryInterceptor(dio));
  if (onNetworkError != null) dio.interceptors.add(NetworkErrorInterceptor(onNetworkError));
  if (kDebugMode) dio.interceptors.add(LogInterceptor(requestHeader: false, responseHeader: false, responseBody: false, logPrint: (o) => debugPrint('[dio] $o')));
  return dio;
}

/// Reports requests that failed because the network failed (not because the server said no), so the connection
/// ViewModel can check right away instead of waiting for its next poll. Passes the error on unchanged.
class NetworkErrorInterceptor extends Interceptor {
  NetworkErrorInterceptor(this.onNetworkError);
  final VoidCallback onNetworkError;

  static bool isNetworkFailure(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isNetworkFailure(err)) onNetworkError();
    handler.next(err);
  }
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

  Future<List<Json>> select(String table, {required String columns, Map<String, String> filters = const {}, List<String> order = const [], int? offset, int? limit, CancelToken? cancel}) async =>
      (await selectCounted(table, columns: columns, filters: filters, order: order, offset: offset, limit: limit, cancel: cancel, count: false)).rows;

  /// One page PLUS the table's total row count. PostgREST reports it in the `Content-Range` header (`0-999/2123`)
  /// when asked with `Prefer: count=exact`, so a big table's remaining pages can be requested together after the
  /// FIRST response.
  /// [total] is null when the header is missing (or hidden from the browser by CORS) — callers then page one by one.
  Future<({List<Json> rows, int? total})> selectCounted(String table,
      {required String columns, Map<String, String> filters = const {}, List<String> order = const [], int? offset, int? limit, CancelToken? cancel, bool count = true}) async {
    try {
      final res = await dio.get<List<dynamic>>(
        table,
        queryParameters: {
          'select': columns,
          ...filters,
          if (order.isNotEmpty) 'order': order.join(','),
          if (offset != null) 'offset': '$offset',
          if (limit != null) 'limit': '$limit',
        },
        options: count ? Options(headers: {'Prefer': 'count=exact'}) : null,
        cancelToken: cancel,
      );
      final range = res.headers.value('content-range'); // '0-999/2123', or '*/0' for an empty table
      return (rows: (res.data ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList(), total: range == null ? null : int.tryParse(range.split('/').last));
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

  Future<dynamic> rpc(String fn, {Map<String, dynamic> params = const {}, bool readOnly = true, CancelToken? cancel}) async {
    try {
      final res = await dio.post<dynamic>('rpc/$fn', data: params, options: Options(extra: {'idempotent': readOnly}), cancelToken: cancel);
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

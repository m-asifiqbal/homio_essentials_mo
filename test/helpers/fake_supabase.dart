/// A tiny in-process stand-in for Supabase's REST API (PostgREST), used as Dio's HTTP adapter.
///
/// It serves `GET /<table>?offset=&limit=` slices from in-memory rows and `POST /rpc/sync_manifest`, records every
/// request, and can be told to be slow, to go offline, to answer 5xx, or to fail one table — so the online data
/// layer (parallel paging, progress, cancellation, retries, error kinds) is tested for real, without a network.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:homio_essentials/core/network/dio_client.dart';

typedef Rows = List<Map<String, dynamic>>;

class FakeSupabase implements HttpClientAdapter {
  FakeSupabase(this.tables, {this.latency = Duration.zero});

  final Map<String, Rows> tables;

  /// Every request takes this long (real time), so concurrency is observable.
  Duration latency;

  /// false → `sync_manifest` answers 404 (an old database without the function).
  bool manifestAvailable = true;

  /// false → responses carry no Content-Range total (e.g. a browser that CORS-hides the header).
  bool sendContentRange = true;

  /// Overrides the row counts reported by the manifest AND by Content-Range (to simulate rows added after the count).
  final countOverride = <String, int>{};

  /// Part of the manifest signature: change it to simulate the server data changing.
  String version = 'v1';

  /// Everything fails with a connection error (phone offline).
  bool offline = false;

  /// Every request times out / answers this HTTP status.
  bool timeout = false;
  int? failStatus;

  /// Only these tables fail (with [failStatus] or a connection error).
  final failTables = <String>{};

  final requests = <RequestOptions>[];
  int cancelled = 0;
  int _inFlight = 0;
  int maxInFlight = 0;

  /// `GET` requests for [table], as their `offset` values.
  List<int> offsetsFor(String table) => [for (final r in requests) if (r.path == table) int.parse('${r.queryParameters['offset'] ?? 0}')];

  int get tableRequests => requests.where((r) => r.path != 'rpc/sync_manifest').length;
  int get manifestRequests => requests.where((r) => r.path == 'rpc/sync_manifest').length;

  /// A Dio wired to this fake, without the production retry delays.
  Dio dio() => Dio(BaseOptions(baseUrl: 'https://fake.supabase.test/rest/v1/'))
    ..transformer = SyncTransformer()
    ..httpClientAdapter = this;

  PostgrestApi api() => PostgrestApi(dio());

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    _inFlight++;
    maxInFlight = math.max(maxInFlight, _inFlight);
    var isCancelled = false;
    cancelFuture?.then((_) => isCancelled = true);
    try {
      // A table that is set to fail fails at once (a refused connection is quick); the others are still slow.
      if (failTables.contains(options.path) && failStatus == null) throw DioException.connectionError(requestOptions: options, reason: 'offline');
      if (latency > Duration.zero) await Future<void>.delayed(latency);
      if (isCancelled) {
        cancelled++;
        throw DioException.requestCancelled(requestOptions: options, reason: 'cancelled');
      }
      if (offline) throw DioException.connectionError(requestOptions: options, reason: 'offline');
      if (timeout) throw DioException.connectionTimeout(timeout: const Duration(seconds: 12), requestOptions: options);
      final table = options.path;
      if (failStatus != null && (failTables.isEmpty || failTables.contains(table))) return _json(options, '{"message":"boom"}', failStatus!);
      if (failTables.contains(table)) throw DioException.connectionError(requestOptions: options, reason: 'offline');

      if (table == 'rpc/sync_manifest') {
        if (!manifestAvailable) return _json(options, '{"message":"function not found"}', 404);
        final rows = [
          for (final e in tables.entries) {'table_name': e.key, 'row_count': countOverride[e.key] ?? e.value.length, 'max_updated_at': version},
        ];
        return _json(options, jsonEncode(rows), 200);
      }
      final all = tables[table];
      if (all == null) return _json(options, '{"message":"no such table"}', 404);
      var data = all;
      // PostgREST equality filters: ?column=eq.value
      for (final f in options.queryParameters.entries) {
        final v = '${f.value}';
        if (v.startsWith('eq.')) data = [for (final r in data) if ('${r[f.key]}' == v.substring(3)) r];
      }
      final offset = int.parse('${options.queryParameters['offset'] ?? 0}');
      final limit = int.parse('${options.queryParameters['limit'] ?? 1000}');
      final slice = data.skip(offset).take(limit).toList();
      final wantsCount = '${options.headers['Prefer'] ?? ''}'.contains('count=exact');
      final total = countOverride[table] ?? all.length;
      final range = slice.isEmpty ? '*/$total' : '$offset-${offset + slice.length - 1}/$total';
      return _json(options, jsonEncode(slice), 200, extra: {if (wantsCount && sendContentRange) 'content-range': [range]});
    } finally {
      _inFlight--;
    }
  }

  ResponseBody _json(RequestOptions o, String body, int status, {Map<String, List<String>> extra = const {}}) =>
      ResponseBody.fromString(body, status, headers: {Headers.contentTypeHeader: ['application/json'], ...extra});
}

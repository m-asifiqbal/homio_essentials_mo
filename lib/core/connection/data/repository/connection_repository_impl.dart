/// ============================================================
/// CONNECTION REPOSITORY (impl) — connectivity_plus for the network, a tiny Dio request for the server
/// ============================================================
library;

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:homio_essentials/core/connection/domain/repository/connection_repository.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/network/dio_client.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  /// [api] must be a client WITHOUT retries and with short timeouts (see `probeDioProvider`): a probe that
  /// takes half a minute to fail is no probe.
  ConnectionRepositoryImpl({required this.api, Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();
  final PostgrestApi api;
  final Connectivity _connectivity;

  static bool _none(List<ConnectivityResult> r) => r.isEmpty || r.every((x) => x == ConnectivityResult.none);

  @override
  Stream<void> get networkChanges => _connectivity.onConnectivityChanged.map((_) {});

  @override
  Future<bool> hasNetwork() async {
    try {
      return !_none(await _connectivity.checkConnectivity());
    } catch (_) {
      return true; // can't tell (unsupported platform): let the server probe decide
    }
  }

  @override
  Future<bool> serverReachable() async {
    try {
      // The smallest real request: one row, one column (~20 bytes).
      await api.select('app_config', columns: 'key', limit: 1);
      return true;
    } on ApiException catch (e) {
      // 4xx / 5xx still means the server answered. Only "no connection" and "no answer in time" are offline.
      return e.kind != ApiErrorKind.offline && e.kind != ApiErrorKind.timeout;
    } catch (_) {
      return false;
    }
  }
}

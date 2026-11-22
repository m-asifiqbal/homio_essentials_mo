/// ============================================================
/// CORE PROVIDERS — singletons resolved once in bootstrap
/// ============================================================
///
///   prefsProvider      SharedPreferences (overridden in bootstrap)
///   dioProvider        Dio for Supabase REST (reports network failures to the connection ViewModel)
///   probeDioProvider   impatient Dio for the connection probe
///   postgrestProvider  select / rpc / insert helper over Dio
/// ============================================================
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/shared/providers/connection_provider.dart';

/// Riverpod 3 re-runs a failed provider up to 10 times with growing delays and keeps showing the LOADER meanwhile —
/// minutes of spinner on a bad connection, and a hammered server. We turn that off: Dio already retries transient
/// failures twice, then the screen shows the typed error with a Retry button and the user decides.
Duration? noAutoRetry(int retryCount, Object error) => null;

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefsProvider is overridden in bootstrap'));

final dioProvider = Provider<Dio>((ref) {
  // A request that fails because the NETWORK failed tells the connection ViewModel, which then checks right away.
  final dio = buildDio(onNetworkError: () => ref.read(connectionControllerProvider.notifier).onRequestFailed());
  ref.onDispose(dio.close);
  return dio;
});

/// A separate, impatient client for the connection probe: no retries, 5 s timeouts, no error reports (a failing
/// probe must not trigger itself).
final probeDioProvider = Provider<Dio>((ref) {
  final dio = buildDio(retry: false, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5));
  ref.onDispose(dio.close);
  return dio;
});

final postgrestProvider = Provider<PostgrestApi>((ref) => PostgrestApi(ref.watch(dioProvider)));

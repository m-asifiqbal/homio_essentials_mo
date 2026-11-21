/// ============================================================
/// CORE PROVIDERS — singletons resolved once in bootstrap
/// ============================================================
///
///   prefsProvider      SharedPreferences (overridden in bootstrap)
///   cacheStoreProvider on-device archive storage (overridden in bootstrap)
///   dioProvider        Dio for Supabase REST
///   postgrestProvider  select / rpc / insert helper over Dio
/// ============================================================
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/core/storage/cache_store.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefsProvider is overridden in bootstrap'));

final cacheStoreProvider = Provider<CacheStore>((ref) => throw UnimplementedError('cacheStoreProvider is overridden in bootstrap'));

final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio();
  ref.onDispose(dio.close);
  return dio;
});

final postgrestProvider = Provider<PostgrestApi>((ref) => PostgrestApi(ref.watch(dioProvider)));

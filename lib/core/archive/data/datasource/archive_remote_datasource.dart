/// ============================================================
/// ARCHIVE REMOTE DATASOURCE — Supabase REST (PostgREST) over Dio
/// ============================================================
///
/// Only published rows are visible to the app's anon key (row-level
/// security), so no status filters are needed here.
///
/// The archive is fetched FAST rather than politely one table after another:
///   1. `sync_manifest` (the change signature) and the first page of every table start together;
///   2. a table that needs more pages gets all of them at once, using the total PostgREST reports with the first page;
///   3. the first failure cancels everything still in flight, so Retry never competes with a stale attempt.
/// ============================================================
library;

import 'package:dio/dio.dart';

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/core/utils/json.dart';

/// What the server says it holds right now: row counts per table and one comparable signature.
class ArchiveManifest {
  const ArchiveManifest(this.counts, this.signature);
  final Map<String, int> counts;
  final String signature;
}

class ArchiveDownload {
  const ArchiveDownload(this.tables, this.signature);
  final Map<String, List<Json>> tables;
  final String signature;
}

class ArchiveRemoteDataSource {
  ArchiveRemoteDataSource(this.api);
  final PostgrestApi api;

  /// PostgREST returns at most this many rows per request.
  static const pageSize = 1000;

  /// table → (columns, unique order key for stable paging)
  static const tables = <String, (String, List<String>)>{
    'remedies': ('id,slug,latin_name,abbreviation,kingdom,family,groups,potencies,forms,external_use,search_keys,source_refs', ['id.asc']),
    'remedy_translations': ('remedy_id,locale,display_name,common_name,summary,origin,preparation,keynotes,machine_fields', ['remedy_id.asc', 'locale.asc']),
    'conditions': ('id,slug,body_system,icon,sort_order', ['id.asc']),
    'condition_translations': ('condition_id,locale,name,description,red_flags,search_keys', ['condition_id.asc', 'locale.asc']),
    'remedy_uses': ('id,remedy_id,condition_id,route,typical_potencies,tags,sort_order', ['id.asc']),
    'remedy_use_translations': ('use_id,locale,title,description,key_difference', ['use_id.asc', 'locale.asc']),
    'age_groups': ('code,min_years,max_years,sort_order,label', ['code.asc']),
    'dosage_rules': ('remedy_id,potency,age_group,context,pellets_min,pellets_max,frequency,note', ['id.asc']),
    'remedy_safety_notes': ('remedy_id,severity,body,sort_order', ['id.asc']),
    'remedy_relations': ('remedy_id,related_remedy_id,relation_type', ['remedy_id.asc', 'related_remedy_id.asc', 'relation_type.asc']),
    'manufacturers': ('id,slug,name,short_name,country,city,website,sold_in_bd', ['id.asc']),
    'products': ('id,remedy_id,manufacturer_id,name,form,potency,pack_size,pack_unit,price_bdt,price_tier', ['id.asc']),
    'contact_channels': ('type,label,value,sort_order', ['id.asc']),
    'app_config': ('key,value', ['key.asc']),
  };

  /// Row counts + last-change time per table, folded into one comparable string.
  Future<ArchiveManifest> fetchManifest({CancelToken? cancel}) async {
    final rows = (await api.rpc('sync_manifest', cancel: cancel) as List?) ?? const [];
    final counts = <String, int>{for (final r in rows) '${r['table_name']}': (r['row_count'] as num?)?.toInt() ?? 0};
    final parts = rows.map((r) => '${r['table_name']}:${r['row_count']}:${r['max_updated_at']}').toList()..sort();
    return ArchiveManifest(counts, parts.join('|'));
  }

  Future<String> fetchSignature({CancelToken? cancel}) async => (await fetchManifest(cancel: cancel)).signature;

  /// Every table, in parallel.
  Future<ArchiveDownload> fetchAll({CancelToken? cancel}) async {
    // Our own token, so a failure here stops OUR requests without poisoning the caller's token for later calls.
    final token = CancelToken();
    cancel?.whenCancel.then((e) => token.cancel(e.error));
    // The manifest only supplies the change signature; if it is unavailable the data still loads.
    final manifest = fetchManifest(cancel: token).then<ArchiveManifest?>((m) => m, onError: (Object _) => null);
    Future<MapEntry<String, List<Json>>> load(String name, (String, List<String>) spec) async => MapEntry(name, await _table(name, spec, token));

    try {
      final entries = await Future.wait([for (final e in tables.entries) load(e.key, e.value)], eagerError: true);
      return ArchiveDownload(Map.fromEntries(entries), (await manifest)?.signature ?? '');
    } catch (_) {
      token.cancel('archive load failed'); // stop the siblings still downloading
      rethrow;
    }
  }

  /// One table. The first page also returns the table's total (Content-Range), so when more pages are needed they
  /// are all requested together. Without a total (header missing) it pages one after another.
  Future<List<Json>> _table(String name, (String, List<String>) spec, CancelToken cancel) async {
    final (columns, order) = spec;
    Future<List<Json>> page(int n) => api.select(name, columns: columns, order: order, offset: n * pageSize, limit: pageSize, cancel: cancel);

    final first = await api.selectCounted(name, columns: columns, order: order, offset: 0, limit: pageSize, cancel: cancel);
    final out = [...first.rows];
    if (out.length < pageSize) return out;

    var next = 1;
    final total = first.total;
    if (total != null && total > pageSize) {
      final pages = (total + pageSize - 1) ~/ pageSize;
      final rest = await Future.wait([for (var n = 1; n < pages; n++) page(n)], eagerError: true);
      for (final r in rest) {
        out.addAll(r);
      }
      next = pages;
      if (rest.isNotEmpty && rest.last.length < pageSize) return out;
    }
    // Rows added since the count (or no count at all): keep going until a short page.
    for (;; next++) {
      final more = await page(next);
      out.addAll(more);
      if (more.length < pageSize) return out;
    }
  }
}

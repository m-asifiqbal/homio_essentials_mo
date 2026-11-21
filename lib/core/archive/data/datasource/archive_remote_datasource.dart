/// ============================================================
/// ARCHIVE REMOTE DATASOURCE — Supabase REST (PostgREST) over Dio
/// ============================================================
///
/// Only published rows are visible to the app's anon key (row-level
/// security), so no status filters are needed here.
/// ============================================================
library;

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/core/utils/json.dart';

class ArchiveRemoteDataSource {
  ArchiveRemoteDataSource(this.api);
  final PostgrestApi api;

  /// table → (columns, unique order key for stable paging)
  static const tables = <String, (String, List<String>)>{
    'remedies': ('id,slug,latin_name,abbreviation,kingdom,family,groups,potencies,forms,external_use,search_keys,source_refs', ['id.asc']),
    'remedy_translations': ('remedy_id,locale,display_name,common_name,summary,origin,preparation,keynotes', ['remedy_id.asc', 'locale.asc']),
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
  Future<String> fetchSignature() async {
    final rows = (await api.rpc('sync_manifest') as List?) ?? const [];
    final parts = rows.map((r) => '${r['table_name']}:${r['row_count']}:${r['max_updated_at']}').toList()..sort();
    return parts.join('|');
  }

  Future<Map<String, List<Json>>> fetchAllTables() async {
    final entries = await Future.wait(tables.entries.map((e) async => MapEntry(e.key, await api.selectAll(e.key, columns: e.value.$1, order: e.value.$2))));
    return Map.fromEntries(entries);
  }
}

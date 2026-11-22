// Downloads the live archive (every table the app syncs) and all book text into two JSON files, using the same
// public anon key and REST calls as the app. They feed test/screens_smoke_real_data_test.dart.
//
//   node tool/fetch_test_fixture.mjs [env.json] [outDir]        (defaults: env.json, build/fixtures)
//   HOMIO_FIXTURE_DIR=build/fixtures flutter test test/screens_smoke_real_data_test.dart
//
// The output goes under build/ (git-ignored): it is a snapshot of real data, not something to commit.
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const envPath = process.argv[2] ?? 'env.json';
const outDir = process.argv[3] ?? 'build/fixtures';
const env = JSON.parse(readFileSync(envPath, 'utf8'));
mkdirSync(outDir, { recursive: true });

async function selectAll(table, columns, order) {
  const rows = [];
  for (let from = 0; ; from += 1000) {
    const res = await fetch(`${env.SUPABASE_URL}/rest/v1/${table}?select=${columns}&order=${order}`, {
      headers: { apikey: env.SUPABASE_ANON_KEY, Authorization: `Bearer ${env.SUPABASE_ANON_KEY}`, Range: `${from}-${from + 999}`, 'Range-Unit': 'items' },
    });
    if (!res.ok) throw new Error(`${table}: HTTP ${res.status}`);
    const page = await res.json();
    rows.push(...page);
    if (page.length < 1000) return rows;
  }
}

// Mirrors lib/core/archive/data/datasource/archive_remote_datasource.dart (table -> columns, stable order).
const tables = {
  remedies: ['id,slug,latin_name,abbreviation,kingdom,family,groups,potencies,forms,external_use,search_keys,source_refs', 'id.asc'],
  remedy_translations: ['remedy_id,locale,display_name,common_name,summary,origin,preparation,keynotes', 'remedy_id.asc,locale.asc'],
  conditions: ['id,slug,body_system,icon,sort_order', 'id.asc'],
  condition_translations: ['condition_id,locale,name,description,red_flags,search_keys', 'condition_id.asc,locale.asc'],
  remedy_uses: ['id,remedy_id,condition_id,route,typical_potencies,tags,sort_order', 'id.asc'],
  remedy_use_translations: ['use_id,locale,title,description,key_difference', 'use_id.asc,locale.asc'],
  age_groups: ['code,min_years,max_years,sort_order,label', 'code.asc'],
  dosage_rules: ['remedy_id,potency,age_group,context,pellets_min,pellets_max,frequency,note', 'id.asc'],
  remedy_safety_notes: ['remedy_id,severity,body,sort_order', 'id.asc'],
  remedy_relations: ['remedy_id,related_remedy_id,relation_type', 'remedy_id.asc,related_remedy_id.asc,relation_type.asc'],
  manufacturers: ['id,slug,name,short_name,country,city,website,sold_in_bd', 'id.asc'],
  products: ['id,remedy_id,manufacturer_id,name,form,potency,pack_size,pack_unit,price_bdt,price_tier', 'id.asc'],
  contact_channels: ['type,label,value,sort_order', 'id.asc'],
  app_config: ['key,value', 'key.asc'],
};

const result = {};
for (const [table, [columns, order]] of Object.entries(tables)) {
  result[table] = await selectAll(table, columns, order);
  console.log(table.padEnd(26), result[table].length);
}
writeFileSync(join(outDir, 'archive_fixture.json'), JSON.stringify({ signature: 'fixture', synced_at: new Date().toISOString(), tables: result }));

const materia = {};
const rows = await selectAll('materia_entries', 'remedy_id,source_book,section,body,source_url,sort_order', 'remedy_id.asc,source_book.asc,sort_order.asc');
for (const r of rows) (materia[r.remedy_id] ??= []).push({ source_book: r.source_book, section: r.section, body: r.body, source_url: r.source_url, sort_order: r.sort_order });
writeFileSync(join(outDir, 'materia_fixture.json'), JSON.stringify(materia));
console.log('materia_entries'.padEnd(26), rows.length, `(${Object.keys(materia).length} remedies)`);
console.log(`written to ${outDir}`);

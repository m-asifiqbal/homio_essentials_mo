import 'package:homio_essentials/core/archive/domain/entities/models.dart';

/// The whole browsable archive, held in memory only (≈1 MB of rows). It is downloaded at every launch and
/// never written to the phone; the raw rows are dropped once the lookup tables below are built.
/// Long book text (materia medica) is fetched per remedy by [MateriaRepository].
class Archive {
  Archive._(this.signature, this.syncedAt);

  /// Server change signature this copy was built from (empty when the manifest was unreadable).
  final String signature;
  final DateTime syncedAt;

  late final List<Remedy> remedies;
  late final Map<String, Remedy> remedyById, remedyBySlug;
  late final List<Condition> conditions;
  late final Map<String, Condition> conditionById, conditionBySlug;
  late final Map<String, List<RemedyUse>> usesByRemedy, usesByCondition;
  late final List<AgeGroup> ageGroups;
  late final List<DoseRule> defaultRules;
  late final Map<String, List<DoseRule>> rulesByRemedy;
  late final Map<String, List<SafetyNote>> safetyByRemedy;
  late final Map<String, List<Relation>> relationsByRemedy;
  late final List<Manufacturer> manufacturers;
  late final Map<String, Manufacturer> manufacturerById;
  late final Map<String, List<Product>> productsByRemedy;
  late final List<ContactChannel> contacts;
  late final Map<String, dynamic> config;

  static Map<String, List<T>> _group<T>(Iterable<T> xs, String? Function(T) key) {
    final m = <String, List<T>>{};
    for (final x in xs) {
      final k = key(x);
      if (k != null) (m[k] ??= []).add(x);
    }
    return m;
  }

  factory Archive.build(Map<String, List<Json>> t, String signature, DateTime syncedAt) {
    final a = Archive._(signature, syncedAt);
    List<Json> rows(String name) => t[name] ?? const [];

    a.remedies = rows('remedies').map(Remedy.from).toList()..sort((x, y) => x.latin.toLowerCase().compareTo(y.latin.toLowerCase()));
    a.remedyById = {for (final r in a.remedies) r.id: r};
    a.remedyBySlug = {for (final r in a.remedies) r.slug: r};
    for (final j in rows('remedy_translations')) {
      final r = a.remedyById[j['remedy_id']];
      if (r == null) continue;
      if (j['locale'] == 'bn') { r.bn = RemedyText.from(j); } else { r.en = RemedyText.from(j); }
    }

    a.conditions = rows('conditions').map(Condition.from).toList()..sort((x, y) => x.sort.compareTo(y.sort));
    a.conditionById = {for (final c in a.conditions) c.id: c};
    a.conditionBySlug = {for (final c in a.conditions) c.slug: c};
    for (final j in rows('condition_translations')) {
      final c = a.conditionById[j['condition_id']];
      if (c == null) continue;
      if (j['locale'] == 'bn') { c.bn = ConditionText.from(j); } else { c.en = ConditionText.from(j); }
    }

    final uses = rows('remedy_uses').map(RemedyUse.from).toList()..sort((x, y) => x.sort.compareTo(y.sort));
    final useById = {for (final u in uses) u.id: u};
    for (final j in rows('remedy_use_translations')) {
      final u = useById[j['use_id']];
      if (u == null) continue;
      if (j['locale'] == 'bn') { u.bn = UseText.from(j); } else { u.en = UseText.from(j); }
    }
    a.usesByRemedy = _group(uses, (u) => u.remedyId);
    a.usesByCondition = _group(uses, (u) => u.conditionId);

    a.ageGroups = rows('age_groups').map(AgeGroup.from).toList()..sort((x, y) => x.sort.compareTo(y.sort));
    final rules = rows('dosage_rules').map(DoseRule.from).toList();
    a.defaultRules = rules.where((r) => r.remedyId == null).toList();
    a.rulesByRemedy = _group(rules.where((r) => r.remedyId != null), (r) => r.remedyId);
    a.safetyByRemedy = _group(rows('remedy_safety_notes').map(SafetyNote.from).toList()..sort((x, y) => x.sort.compareTo(y.sort)), (s) => s.remedyId);
    a.relationsByRemedy = _group(rows('remedy_relations').map(Relation.from), (r) => r.remedyId);
    a.manufacturers = rows('manufacturers').map(Manufacturer.from).toList()..sort((x, y) => x.name.compareTo(y.name));
    a.manufacturerById = {for (final m in a.manufacturers) m.id: m};
    a.productsByRemedy = _group(rows('products').map(Product.from), (p) => p.remedyId);
    a.contacts = rows('contact_channels').map(ContactChannel.from).toList()..sort((x, y) => x.sort.compareTo(y.sort));
    a.config = {for (final j in rows('app_config')) j['key'] as String: j['value']};
    return a;
  }

  /// Test/fixture helper: `{signature, synced_at, tables}` as written by tool/fetch_test_fixture.mjs.
  factory Archive.fromJson(Json j) {
    final tables = (j['tables'] as Map).map((k, v) => MapEntry(k as String, (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()));
    return Archive.build(tables, j['signature'] ?? '', DateTime.tryParse(j['synced_at'] ?? '') ?? DateTime(2000));
  }

  // ---- queries used by view models ----
  List<Remedy> related(Remedy r, {Set<String>? types}) {
    final seen = <String>{};
    return [
      for (final rel in relationsByRemedy[r.id] ?? const <Relation>[])
        if ((types == null || types.contains(rel.type)) && seen.add(rel.relatedId) && remedyById[rel.relatedId] != null) remedyById[rel.relatedId]!,
    ];
  }

  String? relationType(Remedy from, Remedy to) => relationsByRemedy[from.id]?.where((x) => x.relatedId == to.id).firstOrNull?.type;

  /// Remedy-specific rules win; otherwise the default rules (tissue salts use the X rules).
  List<DoseRule> rulesFor(Remedy r) {
    final own = rulesByRemedy[r.id];
    if (own != null && own.isNotEmpty) return own;
    return defaultRules.where((d) => r.tissueSalt ? d.isTablet : !d.isTablet).toList();
  }

  /// Changes once a day; drawn from curated remedies so it always has a Bangla page.
  Remedy? remedyOfTheDay(DateTime now) {
    final pool = remedies.where((r) => r.curated && r.summary(false) != null).toList();
    if (pool.isEmpty) return remedies.isEmpty ? null : remedies.first;
    final day = now.difference(DateTime(now.year)).inDays + now.year * 366;
    return pool[day % pool.length];
  }

  /// First-aid and polychrest remedies, for "Popular" rows.
  List<Remedy> get popular => remedies.where((r) => r.groups.contains('first_aid') || r.groups.contains('polychrest')).toList();

  String? configText(String key, bool bangla, {String field = ''}) {
    final v = config[key];
    final node = field.isEmpty ? v : (v is Map ? v[field] : null);
    return node is Map ? I18n.from(node).of(bangla) : node?.toString();
  }

  bool configFlag(String key, String field, {bool fallback = false}) {
    final v = config[key];
    return v is Map && v[field] is bool ? v[field] as bool : fallback;
  }
}

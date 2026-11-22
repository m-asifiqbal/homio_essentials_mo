/// ============================================================
/// ARCHIVE ENTITIES — remedies, conditions, uses, doses, safety, relations
/// ============================================================
///
/// Immutable-by-convention models built from Supabase rows (snake_case JSON).
/// Bilingual fields fall back to the other language ([I18n.of]).
/// ============================================================
library;

import 'package:homio_essentials/core/utils/json.dart';

export 'package:homio_essentials/core/utils/json.dart';

List<String> strs(dynamic v) => v is List ? v.map((e) => '$e').toList() : const [];

/// A bilingual value stored as {"en": …, "bn": …}. Falls back to the other language.
class I18n {
  const I18n(this.en, this.bn);
  factory I18n.from(dynamic v) => v is Map ? I18n(v['en'] as String?, v['bn'] as String?) : const I18n(null, null);
  final String? en, bn;
  String? of(bool bangla) => bangla ? (bn ?? en) : (en ?? bn);
  bool get isEmpty => en == null && bn == null;
}

class RemedyText {
  const RemedyText({this.displayName, this.common, this.summary, this.origin, this.preparation, this.keynotes = const [], this.machineFields = const {}});
  factory RemedyText.from(Json j) => RemedyText(
        displayName: j['display_name'], common: j['common_name'], summary: j['summary'],
        origin: j['origin'], preparation: j['preparation'], keynotes: strs(j['keynotes']),
        machineFields: strs(j['machine_fields']).toSet(),
      );
  final String? displayName, common, summary, origin, preparation;
  final List<String> keynotes;

  /// Fields translated automatically from the English and not yet checked by an editor
  /// (display_name, common_name, summary, keynotes).
  final Set<String> machineFields;
}

class Remedy {
  Remedy.from(Json j)
      : id = j['id'], slug = j['slug'], latin = j['latin_name'], abbr = j['abbreviation'], kingdom = j['kingdom'],
        family = j['family'], groups = strs(j['groups']), potencies = strs(j['potencies']), forms = strs(j['forms']),
        externalUse = j['external_use'] == true, searchKeys = strs(j['search_keys']),
        sourceRefs = (j['source_refs'] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

  final String id, slug, latin;
  final String? abbr, kingdom, family;
  final List<String> groups, potencies, forms, searchKeys;
  final bool externalUse;
  final List<Json> sourceRefs;
  RemedyText? en, bn;

  /// Curated remedies carry potencies/forms and an editor-written Bangla translation; book-only ones do not
  /// (an automatic Bangla translation does not make a remedy curated).
  bool get curated => potencies.isNotEmpty || (bn?.summary != null && !bn!.machineFields.contains('summary'));
  bool get tissueSalt => groups.contains('tissue_salt');
  String? common(bool bangla) => (bangla ? bn?.common : null) ?? en?.common;
  String? bnName() => bn?.displayName;
  String? summary(bool bangla) => (bangla ? bn?.summary : null) ?? en?.summary;
  bool summaryIsFallback(bool bangla) => bangla && bn?.summary == null && en?.summary != null;

  /// Keynotes in the reading language (Bangla when translated, else Allen's English).
  List<String> keynotes(bool bangla) {
    final b = bn?.keynotes ?? const <String>[];
    return bangla && b.isNotEmpty ? b : (en?.keynotes ?? const []);
  }

  /// This Bangla field was translated automatically (show a note so readers can check the English).
  bool autoBangla(bool bangla, String field) => bangla && (bn?.machineFields.contains(field) ?? false);
  String get initial => latin.isEmpty ? '?' : latin[0].toUpperCase();
}

class ConditionText {
  const ConditionText({required this.name, this.description, this.redFlags, this.keys = const []});
  factory ConditionText.from(Json j) =>
      ConditionText(name: j['name'] ?? '', description: j['description'], redFlags: j['red_flags'], keys: strs(j['search_keys']));
  final String name;
  final String? description, redFlags;
  final List<String> keys;
}

class Condition {
  Condition.from(Json j) : id = j['id'], slug = j['slug'], bodySystem = j['body_system'], icon = j['icon'], sort = j['sort_order'] ?? 0;
  final String id, slug;
  final String? bodySystem, icon;
  final int sort;
  ConditionText? en, bn;
  String name(bool bangla) => (bangla ? bn?.name : null) ?? en?.name ?? slug;
  String? redFlags(bool bangla) => (bangla ? bn?.redFlags : null) ?? en?.redFlags;
  String? description(bool bangla) => (bangla ? bn?.description : null) ?? en?.description;
}

class UseText {
  const UseText({this.title, this.description, this.keyDifference});
  factory UseText.from(Json j) => UseText(title: j['title'], description: j['description'], keyDifference: j['key_difference']);
  final String? title, description, keyDifference;
}

class RemedyUse {
  RemedyUse.from(Json j)
      : id = j['id'], remedyId = j['remedy_id'], conditionId = j['condition_id'], route = j['route'] ?? 'internal',
        typicalPotencies = strs(j['typical_potencies']), tags = strs(j['tags']), sort = j['sort_order'] ?? 0;
  final String id, remedyId, route;
  final String? conditionId;
  final List<String> typicalPotencies, tags;
  final int sort;
  UseText? en, bn;
  String? description(bool bangla) => (bangla ? bn?.description : null) ?? en?.description;
  String? keyDifference(bool bangla) => (bangla ? bn?.keyDifference : null) ?? en?.keyDifference;
  String? title(bool bangla) => (bangla ? bn?.title : null) ?? en?.title;
}

class AgeGroup {
  AgeGroup.from(Json j) : code = j['code'], minYears = j['min_years'] ?? 0, maxYears = j['max_years'], sort = j['sort_order'] ?? 0, label = I18n.from(j['label']);
  final String code;
  final int minYears, sort;
  final int? maxYears;
  final I18n label;
}

class DoseRule {
  DoseRule.from(Json j)
      : remedyId = j['remedy_id'], potency = j['potency'], ageGroup = j['age_group'], context = j['context'] ?? 'acute',
        min = j['pellets_min'], max = j['pellets_max'], frequency = I18n.from(j['frequency']), note = I18n.from(j['note']);
  final String? remedyId;
  final String potency, ageGroup, context;
  final int? min, max;
  final I18n frequency, note;
  bool get isTablet => potency.toUpperCase().endsWith('X');
  String get amount => min == null ? '—' : (max == null || max == min ? '$min' : '$min–$max');
}

class SafetyNote {
  SafetyNote.from(Json j) : remedyId = j['remedy_id'], severity = j['severity'] ?? 'caution', body = I18n.from(j['body']), sort = j['sort_order'] ?? 0;
  final String remedyId, severity;
  final I18n body;
  final int sort;
}

class Relation {
  Relation.from(Json j) : remedyId = j['remedy_id'], relatedId = j['related_remedy_id'], type = j['relation_type'] ?? 'compare';
  final String remedyId, relatedId, type;
}

class Manufacturer {
  Manufacturer.from(Json j)
      : id = j['id'], slug = j['slug'], name = j['name'], shortName = j['short_name'], country = j['country'], city = j['city'],
        website = j['website'], soldInBd = j['sold_in_bd'];
  final String id, slug, name;
  final String? shortName, country, city, website;
  final bool? soldInBd;
}

class Product {
  Product.from(Json j)
      : id = j['id'], remedyId = j['remedy_id'], manufacturerId = j['manufacturer_id'], name = j['name'], form = j['form'],
        potency = j['potency'], packSize = (j['pack_size'] as num?)?.toDouble(), packUnit = j['pack_unit'],
        price = (j['price_bdt'] as num?)?.toDouble(), tier = j['price_tier'];
  final String id, manufacturerId, name, form;
  final String? remedyId, potency, packUnit, tier;
  final double? packSize, price;
}

class ContactChannel {
  ContactChannel.from(Json j) : type = j['type'], label = I18n.from(j['label']), value = j['value'], sort = j['sort_order'] ?? 0;
  final String type, value;
  final I18n label;
  final int sort;
}


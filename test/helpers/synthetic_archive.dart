/// A small hand-made archive covering the shapes the details page must survive:
///   • arnica-montana — everything present (uses, doses, keynotes, safety, relations, long book text)
///   • bare-remedy    — nothing but a name: every optional section is empty
library;

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';

/// The raw rows (table name → rows) the archive is built from; also what the fake server serves.
Map<String, List<Map<String, dynamic>>> syntheticTables({bool withDefaultDoseRules = true}) => {
      'remedies': [
        {
          'id': 'r1', 'slug': 'arnica-montana', 'latin_name': 'Arnica montana', 'abbreviation': 'Arn.', 'kingdom': 'plant', 'family': 'Asteraceae',
          'groups': ['first_aid', 'polychrest'], 'potencies': ['6C', '30C', '200C'], 'forms': ['globules', 'dilution'], 'external_use': true,
          'search_keys': ['arnika'], 'source_refs': [{'title': 'Boericke', 'scan': {'page': 71}}],
        },
        {'id': 'r2', 'slug': 'bare-remedy', 'latin_name': 'Bare remedy', 'search_keys': <String>[], 'source_refs': <Map<String, dynamic>>[]},
        for (var i = 3; i <= 9; i++) {'id': 'r$i', 'slug': 'rel-$i', 'latin_name': 'Related $i', 'kingdom': 'mineral', 'search_keys': <String>[]},
      ],
      'remedy_translations': [
        {
          'remedy_id': 'r1', 'locale': 'en', 'common_name': "Leopard's bane", 'summary': 'The first remedy for injuries: bruised, sore feeling after falls and blows.',
          'keynotes': [for (var i = 1; i <= 8; i++) 'Keynote number $i — a characteristic symptom written as a full sentence.'],
        },
        {'remedy_id': 'r1', 'locale': 'bn', 'display_name': 'আর্নিকা মন্টানা', 'common_name': 'লেপার্ড’স বেন', 'summary': 'আঘাত, থেঁতলানো ও ব্যথার প্রথম ওষুধ।'},
      ],
      'conditions': [
        {'id': 'c1', 'slug': 'injury', 'sort_order': 1},
      ],
      'condition_translations': [
        {'condition_id': 'c1', 'locale': 'en', 'name': 'Injury & bruising'},
        {'condition_id': 'c1', 'locale': 'bn', 'name': 'আঘাত ও থেঁতলানো', 'machine_translated': true},
      ],
      'remedy_uses': [
        {'id': 'u1', 'remedy_id': 'r1', 'condition_id': 'c1', 'route': 'internal', 'typical_potencies': ['30C'], 'tags': ['source:boericke'], 'sort_order': 1},
      ],
      'remedy_use_translations': [
        {'use_id': 'u1', 'locale': 'en', 'title': 'Injury', 'description': 'Sore, bruised feeling after falls and blows.', 'key_difference': 'Says nothing is wrong.'},
      ],
      'age_groups': [
        for (final (i, g) in [('infant', 0, 2, 'Infants', 'শিশু'), ('child', 3, 12, 'Children', 'শিশু/কিশোর'), ('adult', 13, 59, 'Adults', 'প্রাপ্তবয়স্ক'), ('senior', 60, null, 'Seniors', 'প্রবীণ')].indexed)
          {'code': g.$1, 'min_years': g.$2, 'max_years': g.$3, 'sort_order': i, 'label': {'en': g.$4, 'bn': g.$5}},
      ],
      'dosage_rules': [
        if (withDefaultDoseRules)
          for (final p in ['6C', '30C', '200C'])
            for (final a in ['infant', 'child', 'adult', 'senior'])
              {
                'remedy_id': null, 'potency': p, 'age_group': a, 'context': 'acute', 'pellets_min': 2, 'pellets_max': 4,
                'frequency': {'en': 'Every 1–2 hours for 3–4 doses, then 3 times a day', 'bn': 'প্রতি ১–২ ঘণ্টায় ৩–৪ বার'}, 'note': null,
              },
      ],
      'remedy_safety_notes': [
        {'remedy_id': 'r1', 'severity': 'caution', 'body': {'en': 'Do not use on broken skin.', 'bn': 'কাটা চামড়ায় ব্যবহার করবেন না।'}, 'sort_order': 1},
      ],
      'remedy_relations': [
        for (var i = 3; i <= 9; i++) {'remedy_id': 'r1', 'related_remedy_id': 'r$i', 'relation_type': ['compare', 'complementary', 'antidote'][i % 3]},
      ],
      'manufacturers': <Map<String, dynamic>>[],
      'products': <Map<String, dynamic>>[],
      'contact_channels': <Map<String, dynamic>>[],
      'app_config': <Map<String, dynamic>>[],
    };

Archive buildSyntheticArchive({bool withDefaultDoseRules = true}) =>
    Archive.build(syntheticTables(withDefaultDoseRules: withDefaultDoseRules), 'synthetic', DateTime(2026, 11, 22));

/// Long, realistic book text for arnica so the page is tall enough to scroll through every section.
Map<String, List<MateriaEntry>> syntheticMateria() => {
      'r1': [
        for (final (i, s) in ['Overview', 'Mind', 'Head', 'Eyes', 'Stomach', 'Back', 'Extremities', 'Skin', 'Worse', 'Better', 'Relationship'].indexed)
          MateriaEntry.from({'source_book': 'boericke', 'section': s, 'body': 'Boericke on $s. ${'Sore, lame, bruised feeling all through the body, as if beaten. ' * 4}', 'sort_order': i}),
      ],
    };

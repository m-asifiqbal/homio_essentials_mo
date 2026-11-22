/// ============================================================
/// REMEDY PROVIDERS — detail view data, book text, dose picker state
/// ============================================================
///
///   remedyDetailProvider(slug)  everything the five tabs show, from the archive
///   materiaProvider(remedyId)   source-book sections (always from the server; the repository remembers recent ones in memory)
///   dosageControllerProvider(slug) selected potency + age group
/// ============================================================
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

/// A related remedy and how Boericke relates it ("compare", "antidote"…).
typedef RelatedRemedy = ({Remedy remedy, String type});

@immutable
class RemedyDetail {
  const RemedyDetail({
    required this.remedy, required this.uses, required this.safety, required this.related, required this.rules,
    required this.ageGroups, required this.products, required this.conditionsById, required this.manufacturerNames, this.typicalDose,
  });
  final Remedy remedy;
  final List<RemedyUse> uses;
  final List<SafetyNote> safety;
  final List<RelatedRemedy> related;
  final List<DoseRule> rules;
  final List<AgeGroup> ageGroups;
  final List<Product> products;
  final Map<String, Condition> conditionsById;
  final Map<String, String> manufacturerNames;

  /// Adult 30C (or 6X for tissue salts) — shown only for reviewed remedies.
  final DoseRule? typicalDose;

  static const potencyOrder = ['Q', '1X', '3X', '6X', '12X', '30X', '3C', '6C', '12C', '30C', '200C', '1M', '10M', '50M', 'CM'];
  List<String> get potencies {
    int rank(String p) => potencyOrder.contains(p) ? potencyOrder.indexOf(p) : potencyOrder.length;
    return <String>{for (final x in rules) x.potency}.toList()..sort((a, b) => rank(a).compareTo(rank(b)));
  }
}

/// null inside AsyncData = no remedy with this slug.
final remedyDetailProvider = Provider.autoDispose.family<AsyncValue<RemedyDetail?>, String>((ref, slug) {
  return ref.watch(archiveProvider).whenData((a) {
    final r = a.remedyBySlug[slug];
    if (r == null) return null;
    final rules = a.rulesFor(r);
    final typical = r.curated
        ? (rules.where((x) => x.ageGroup == 'adult' && x.potency == (r.tissueSalt ? '6X' : '30C')).firstOrNull ?? rules.where((x) => x.ageGroup == 'adult').firstOrNull)
        : null;
    final seen = <String>{};
    return RemedyDetail(
      remedy: r,
      uses: a.usesByRemedy[r.id] ?? const [],
      safety: a.safetyByRemedy[r.id] ?? const [],
      related: [
        for (final rel in a.relationsByRemedy[r.id] ?? const <Relation>[])
          if (a.remedyById[rel.relatedId] != null && seen.add('${rel.relatedId}:${rel.type}')) (remedy: a.remedyById[rel.relatedId]!, type: rel.type),
      ],
      rules: rules,
      ageGroups: a.ageGroups,
      products: a.productsByRemedy[r.id] ?? const [],
      conditionsById: a.conditionById,
      manufacturerNames: {for (final m in a.manufacturers) m.id: m.name},
      typicalDose: typical,
    );
  });
});

final materiaProvider = FutureProvider.autoDispose.family<List<MateriaEntry>, String>(
    (ref, remedyId) => ref.watch(materiaRepositoryProvider).forRemedy(remedyId));

@immutable
class DosageUiState {
  const DosageUiState({this.potency, this.ageGroup = 'adult'});
  final String? potency; // null = default (30C / first)
  final String ageGroup;
}

class DosageController extends Notifier<DosageUiState> {
  DosageController(this.slug);
  final String slug;

  @override
  DosageUiState build() => const DosageUiState();
  void setPotency(String p) => state = DosageUiState(potency: p, ageGroup: state.ageGroup);
  void setAge(String a) => state = DosageUiState(potency: state.potency, ageGroup: a);
}

final dosageControllerProvider = NotifierProvider.autoDispose.family<DosageController, DosageUiState, String>(DosageController.new);

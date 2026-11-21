/// Condition page data: the symptom plus each linked remedy and its key difference.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

@immutable
class ConditionDetail {
  const ConditionDetail({required this.condition, required this.entries});
  final Condition condition;
  final List<({Remedy remedy, RemedyUse use})> entries;
}

final conditionDetailProvider = Provider.autoDispose.family<AsyncValue<ConditionDetail?>, String>((ref, slug) {
  return ref.watch(archiveProvider).whenData((a) {
    final cd = a.conditionBySlug[slug];
    if (cd == null) return null;
    return ConditionDetail(condition: cd, entries: [
      for (final u in a.usesByCondition[cd.id] ?? const <RemedyUse>[])
        if (a.remedyById[u.remedyId] != null) (remedy: a.remedyById[u.remedyId]!, use: u),
    ]);
  });
});

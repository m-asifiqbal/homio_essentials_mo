/// ============================================================
/// HOME PROVIDERS — everything the Home tab shows, derived from the archive
/// ============================================================
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

enum DayPart { morning, afternoon, evening }

@immutable
class HomeUiState {
  const HomeUiState({
    required this.remedyOfDay, required this.firstAid, required this.recent, required this.conditions,
    required this.ageGroups, required this.remedyCount, required this.conditionCount, required this.canStudy, required this.dayPart,
  });
  final Remedy? remedyOfDay;
  final List<Remedy> firstAid, recent;
  final List<Condition> conditions;
  final List<AgeGroup> ageGroups;
  final int remedyCount, conditionCount;
  final bool canStudy;
  final DayPart dayPart;
}

DayPart dayPartOf(DateTime t) => t.hour < 12 ? DayPart.morning : (t.hour < 17 ? DayPart.afternoon : DayPart.evening);

final homeStateProvider = Provider.autoDispose<AsyncValue<HomeUiState>>((ref) {
  final history = ref.watch(historyProvider);
  final canStudy = ref.watch(settingsProvider.select((s) => s.canStudy));
  return ref.watch(archiveProvider).whenData((a) {
    final now = DateTime.now();
    return HomeUiState(
      remedyOfDay: a.remedyOfTheDay(now),
      firstAid: a.remedies.where((r) => r.groups.contains('first_aid')).take(10).toList(),
      recent: history.map((s) => a.remedyBySlug[s]).whereType<Remedy>().take(3).toList(),
      conditions: a.conditions.take(10).toList(),
      ageGroups: a.ageGroups,
      remedyCount: a.remedies.length,
      conditionCount: a.conditions.length,
      canStudy: canStudy,
      dayPart: dayPartOf(now),
    );
  });
});

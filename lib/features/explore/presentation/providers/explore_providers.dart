/// ============================================================
/// EXPLORE PROVIDERS — segment, kingdom filter, A–Z list with letter index
/// ============================================================
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

enum ExploreSegment { remedies, symptoms, companies }

@immutable
class ExploreUiState {
  const ExploreUiState({this.segment = ExploreSegment.remedies, this.kingdom});
  final ExploreSegment segment;
  final String? kingdom; // null = all
  ExploreUiState copyWith({ExploreSegment? segment, String? Function()? kingdom}) =>
      ExploreUiState(segment: segment ?? this.segment, kingdom: kingdom == null ? this.kingdom : kingdom());
}

class ExploreController extends Notifier<ExploreUiState> {
  @override
  ExploreUiState build() => const ExploreUiState();
  void setSegment(ExploreSegment s) => state = state.copyWith(segment: s);
  void setKingdom(String? k) => state = state.copyWith(kingdom: () => k);
}

final exploreControllerProvider = NotifierProvider<ExploreController, ExploreUiState>(ExploreController.new);

/// One line of the A–Z list: a letter header or a remedy.
sealed class AzItem {}

class AzHeader extends AzItem {
  AzHeader(this.letter);
  final String letter;
}

class AzRemedy extends AzItem {
  AzRemedy(this.remedy);
  final Remedy remedy;
}

@immutable
class AzList {
  const AzList({required this.items, required this.letterIndex, required this.kingdomCounts, required this.total});
  final List<AzItem> items;

  /// letter → index of its header in [items].
  final Map<String, int> letterIndex;
  final Map<String, int> kingdomCounts;
  final int total;
}

final azListProvider = Provider<AsyncValue<AzList>>((ref) {
  final kingdom = ref.watch(exploreControllerProvider.select((s) => s.kingdom));
  return ref.watch(archiveProvider).whenData((a) {
    final counts = <String, int>{};
    for (final r in a.remedies) {
      counts[r.kingdom ?? 'other'] = (counts[r.kingdom ?? 'other'] ?? 0) + 1;
    }
    final list = kingdom == null ? a.remedies : a.remedies.where((r) => (r.kingdom ?? 'other') == kingdom);
    final items = <AzItem>[];
    final index = <String, int>{};
    for (final r in list) {
      if (!index.containsKey(r.initial)) {
        index[r.initial] = items.length;
        items.add(AzHeader(r.initial));
      }
      items.add(AzRemedy(r));
    }
    return AzList(items: items, letterIndex: index, kingdomCounts: counts, total: list.length);
  });
});

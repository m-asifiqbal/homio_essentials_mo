/// Saved remedies and recent history, resolved against the archive.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';

typedef SavedLists = ({List<Remedy> saved, List<Remedy> history});

final savedListsProvider = Provider.autoDispose<AsyncValue<SavedLists>>((ref) {
  final saved = ref.watch(savedProvider);
  final history = ref.watch(historyProvider);
  return ref.watch(archiveProvider).whenData((a) => (
        saved: saved.map((s) => a.remedyBySlug[s]).whereType<Remedy>().toList(),
        history: history.map((s) => a.remedyBySlug[s]).whereType<Remedy>().take(15).toList(),
      ));
});

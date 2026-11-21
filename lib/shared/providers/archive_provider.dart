/// ============================================================
/// ARCHIVE PROVIDER — the app-wide offline archive and its sync state
/// ============================================================
///
///   archiveProvider    cached archive first (instant, offline), then a
///                      background check; replaced when the server changed
///   syncStateProvider  idle / syncing / offline / failed (banner, Settings)
///   cacheSizeProvider  bytes on the device (Offline & data)
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

enum SyncState { idle, syncing, offline, failed }

class SyncStateController extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;
  void set(SyncState s) => state = s;
}

final syncStateProvider = NotifierProvider<SyncStateController, SyncState>(SyncStateController.new);

class ArchiveController extends AsyncNotifier<Archive> {
  @override
  Future<Archive> build() async {
    final repo = ref.read(archiveRepositoryProvider);
    final cached = await repo.loadCached();
    if (cached != null) {
      Future.microtask(refresh);
      return cached;
    }
    final sync = ref.read(syncStateProvider.notifier)..set(SyncState.syncing);
    try {
      final fresh = await repo.sync(force: true);
      sync.set(SyncState.idle);
      return fresh!;
    } catch (_) {
      sync.set(SyncState.offline);
      rethrow;
    }
  }

  /// Checks the server; swaps in the new archive only when something changed.
  Future<void> refresh({bool force = false}) async {
    final sync = ref.read(syncStateProvider.notifier)..set(SyncState.syncing);
    try {
      final fresh = await ref.read(archiveRepositoryProvider).sync(current: state.value, force: force);
      if (fresh != null) state = AsyncData(fresh);
      sync.set(SyncState.idle);
    } catch (_) {
      sync.set(state.hasValue ? SyncState.offline : SyncState.failed);
      if (!state.hasValue) ref.invalidateSelf();
    }
  }
}

final archiveProvider = AsyncNotifierProvider<ArchiveController, Archive>(ArchiveController.new);

final cacheSizeProvider = FutureProvider.autoDispose<int>((ref) {
  ref.watch(archiveProvider);
  return ref.read(archiveRepositoryProvider).cacheSizeBytes();
});

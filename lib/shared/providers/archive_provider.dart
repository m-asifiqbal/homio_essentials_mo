/// ============================================================
/// ARCHIVE PROVIDER — the app-wide archive, downloaded fresh and held in memory
/// ============================================================
///
///   archiveProvider    loads from the server at launch (loading → data | error); nothing is saved on the phone
///   syncStateProvider  idle / syncing / offline — the state of the LATER checks (banner, Settings)
///
/// After the first load the app browses and searches from memory (instant). It re-checks the server when it
/// returns to the foreground after a while, on pull-to-refresh, and when the user taps the banner / Refresh.
/// ============================================================
library;

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

enum SyncState { idle, syncing, offline }

class SyncStateController extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;
  void set(SyncState s) => state = s;
}

final syncStateProvider = NotifierProvider<SyncStateController, SyncState>(SyncStateController.new);

class ArchiveController extends AsyncNotifier<Archive> {
  /// Coming back to the app after this long triggers a quiet "has anything changed?" check.
  static const staleAfter = Duration(minutes: 10);

  DateTime _checkedAt = DateTime.now();
  Future<void>? _refreshing;
  CancelToken? _cancel;

  @override
  Future<Archive> build() async {
    final cancel = _cancel = CancelToken();
    ref.onDispose(() => cancel.cancel('archive provider disposed')); // Retry never races a stale attempt
    final lifecycle = AppLifecycleListener(onResume: _onResume);
    ref.onDispose(lifecycle.dispose);

    // Don't touch other providers while the widget tree that asked for this one is still building.
    await Future<void>.value();
    final archive = await ref.read(archiveRepositoryProvider).load(cancel: cancel);
    _checkedAt = DateTime.now();
    ref.read(syncStateProvider.notifier).set(SyncState.idle);
    return archive;
  }

  /// Asks the server whether anything changed; swaps the new archive in only when it did.
  /// With nothing loaded yet (the first download failed), this simply starts the download again.
  Future<void> refresh({bool force = false}) {
    final current = state.value;
    if (current == null) {
      if (!state.isLoading) ref.invalidateSelf(); // the first download failed: start it again
      return Future.value();
    }
    return _refreshing ??= _refresh(current, force).whenComplete(() {
      _refreshing = null;
    });
  }

  Future<void> _refresh(Archive current, bool force) async {
    final sync = ref.read(syncStateProvider.notifier)..set(SyncState.syncing);
    try {
      final fresh = await ref.read(archiveRepositoryProvider).refresh(current, force: force, cancel: _cancel);
      if (fresh != null) state = AsyncData(fresh);
      _checkedAt = DateTime.now();
      sync.set(SyncState.idle);
    } catch (_) {
      sync.set(SyncState.offline); // what is already in memory stays usable; the banner offers a retry
    }
  }

  void _onResume() {
    if (state.hasError) return ref.invalidateSelf();
    final stale = DateTime.now().difference(_checkedAt) > staleAfter;
    if (state.hasValue && (stale || ref.read(syncStateProvider) == SyncState.offline)) refresh();
  }
}

final archiveProvider = AsyncNotifierProvider<ArchiveController, Archive>(ArchiveController.new);

/// ============================================================
/// CONNECTION VIEWMODEL — is the app online right now? (the app works online only)
/// ============================================================
///
///   View        `ConnectionGate` watches [ConnectionUiState] and covers the whole app with the no-internet
///               screen while `online` is false; its Try again button calls [ConnectionController.retry].
///   ViewModel   [ConnectionController] (this file): decides online/offline and keeps checking.
///   Repository  `ConnectionRepository` (contract in core/connection/domain, impl in core/connection/data).
///
/// What makes the app go OFFLINE (the whole app is then replaced by the no-internet screen):
///   • the phone reports no network at all (Wi-Fi and mobile data off, airplane mode) — at once;
///   • our server doesn't answer a tiny probe twice in a row (Wi-Fi without internet, captive portal, outage);
///   • a real request just failed with a network error AND the probe fails too;
///   • the person taps Try again and the check fails.
/// What brings it back ONLINE: any successful check — they run every few seconds while offline, when the
/// phone's network changes, and when the app returns to the foreground. Coming back online refreshes the archive.
/// ============================================================
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/connection/domain/repository/connection_repository.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

/// How often and how patiently the connection is checked. Tests override it (see [ConnectionTiming.off]).
@immutable
class ConnectionTiming {
  const ConnectionTiming({
    this.pollOnline = const Duration(seconds: 20),
    this.pollOffline = const Duration(seconds: 3),
    this.changeDebounce = const Duration(milliseconds: 1500),
    this.failuresBeforeOffline = 2,
    this.requestCheckGap = const Duration(seconds: 2),
  });

  /// Probe interval while online (a ~20-byte request; paused while the app is in the background).
  final Duration pollOnline;

  /// Probe interval while offline, so the app comes back by itself. Duration.zero = no polling.
  final Duration pollOffline;

  /// Wait after a network change before checking (Wi-Fi ↔ mobile data passes through "none" for a moment).
  final Duration changeDebounce;

  /// Consecutive failed probes (with a network present) before the app counts as offline.
  final int failuresBeforeOffline;

  /// Minimum gap between checks triggered by failing requests.
  final Duration requestCheckGap;

  /// No timers at all: a check happens only when something asks for it. For tests that don't test connectivity.
  static const off = ConnectionTiming(pollOnline: Duration.zero, pollOffline: Duration.zero, changeDebounce: Duration.zero);
}

final connectionTimingProvider = Provider<ConnectionTiming>((ref) => const ConnectionTiming());

@immutable
class ConnectionUiState {
  const ConnectionUiState({this.online = true, this.checking = false});

  /// False → the whole app is covered by the no-internet screen.
  final bool online;

  /// A check the person asked for (Try again) is running.
  final bool checking;

  ConnectionUiState copyWith({bool? online, bool? checking}) => ConnectionUiState(online: online ?? this.online, checking: checking ?? this.checking);

  @override
  bool operator ==(Object other) => other is ConnectionUiState && other.online == online && other.checking == checking;

  @override
  int get hashCode => Object.hash(online, checking);
}

class ConnectionController extends Notifier<ConnectionUiState> {
  Timer? _poll, _debounce, _requestCooldown;
  StreamSubscription<void>? _changes;
  bool _foreground = true, _running = false;
  int _failures = 0;

  ConnectionRepository get _repo => ref.read(connectionRepositoryProvider);
  ConnectionTiming get _timing => ref.read(connectionTimingProvider);

  @override
  ConnectionUiState build() {
    _changes = _repo.networkChanges.listen(_onNetworkChanged);
    final lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    ref.onDispose(() {
      _poll?.cancel();
      _debounce?.cancel();
      _requestCooldown?.cancel();
      _changes?.cancel();
      lifecycle.dispose();
    });
    // The first look is only "does the phone have a network?" — the archive download that follows is itself
    // the server probe, so launch doesn't pay for an extra request.
    Future<void>.microtask(() => check(server: false));
    return const ConnectionUiState();
  }

  /// The Try again button: check now, show "Checking…", and go (or stay) offline on failure.
  Future<void> retry() => check(decisive: true, showChecking: true);

  /// Called by the Dio interceptor when a request failed because the network failed: confirm with a probe now
  /// (rate limited — a burst of failing requests is one check).
  void onRequestFailed() {
    if (_running || _requestCooldown != null) return;
    _requestCooldown = Timer(_timing.requestCheckGap, () => _requestCooldown = null);
    check(decisive: true);
  }

  /// One check. [decisive]: a failure goes offline immediately instead of waiting for a second failed probe.
  /// [server]: also probe our server (otherwise only the phone's network is looked at).
  Future<void> check({bool decisive = false, bool showChecking = false, bool server = true}) async {
    if (_running) return;
    _running = true;
    if (showChecking) state = state.copyWith(checking: true);
    try {
      final network = await _repo.hasNetwork();
      final ok = network && (!server || await _repo.serverReachable());
      if (!ref.mounted) return;
      if (ok) {
        _failures = 0;
        _setOnline(true);
      } else {
        _failures++;
        if (!network || decisive || _failures >= _timing.failuresBeforeOffline) _setOnline(false);
      }
    } finally {
      _running = false;
      if (ref.mounted) {
        if (state.checking) state = state.copyWith(checking: false);
        _schedule();
      }
    }
  }

  void _setOnline(bool online) {
    if (state.online == online) return;
    state = state.copyWith(online: online);
    // Back online: pick up anything that changed on the server while we were away (or restart a failed first load).
    if (online) ref.read(archiveProvider.notifier).refresh();
  }

  void _onNetworkChanged(void _) {
    _debounce?.cancel();
    _debounce = Timer(_timing.changeDebounce, check);
  }

  void _onLifecycle(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _foreground = true;
      check();
    } else if (s == AppLifecycleState.paused || s == AppLifecycleState.hidden) {
      _foreground = false; // no polling in the background: nothing is on screen to protect
      _poll?.cancel();
    }
  }

  /// Next probe: seldom while online, often while offline (so the app comes back by itself).
  void _schedule() {
    _poll?.cancel();
    if (!_foreground) return;
    final wait = state.online ? _timing.pollOnline : _timing.pollOffline;
    if (wait == Duration.zero) return;
    _poll = Timer(wait, check);
  }
}

final connectionControllerProvider = NotifierProvider<ConnectionController, ConnectionUiState>(ConnectionController.new);

/// ============================================================
/// CONNECTION GATE (View) — the app works online only
/// ============================================================
///
/// Wraps the whole router. While [ConnectionUiState.online] is false the app's pages are hidden (`Offstage`: not
/// drawn, not tappable, not read out by TalkBack) and a full-screen "No internet connection" page is shown
/// instead — on top of every route AND dialog. The pages stay mounted underneath, so when the connection comes
/// back the person is exactly where they were; the data is refreshed from the server by the ViewModel.
///
/// This widget holds no logic: it watches the ViewModel (`connectionControllerProvider`) and calls `retry()`.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/connection_provider.dart';

class ConnectionGate extends ConsumerStatefulWidget {
  const ConnectionGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends ConsumerState<ConnectionGate> with WidgetsBindingObserver {
  bool _online = true;

  @override
  void initState() {
    super.initState();
    // Registered here (before the Router below us registers its own back handler), so it is asked FIRST:
    // while the no-internet page covers the app, Android back must not quietly pop pages behind it.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async => !_online; // true = handled (ignored) while offline

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connectionControllerProvider);
    _online = state.online;
    return Stack(fit: StackFit.expand, children: [
      Offstage(offstage: !state.online, child: TickerMode(enabled: state.online, child: widget.child)),
      if (!state.online) Positioned.fill(child: _NoInternetPage(checking: state.checking)),
    ]);
  }
}

class _NoInternetPage extends ConsumerWidget {
  const _NoInternetPage({required this.checking});
  final bool checking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Scaffold(
        backgroundColor: context.hm.bg,
        body: SafeArea(
          child: Column(children: [
            const SizedBox(height: 24),
            const HmLogo(size: 40),
            Expanded(
              child: HmErrorState(
                error: const ApiException(ApiErrorKind.offline),
                retrying: checking,
                footnote: context.l.needsInternet,
                onRetry: () => ref.read(connectionControllerProvider.notifier).retry(),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

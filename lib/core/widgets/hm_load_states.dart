/// ============================================================
/// HM LOAD STATES — the slow-connection hint and the error screen every online screen shares
/// ============================================================
///
/// Loading itself is ALWAYS the shimmer skeleton (HmSkeleton / SkeletonList) — one loading look in the app.
/// [HmSlowLoadHint]  under a skeleton: silent at first, a hint on a slow connection, Try again after a long wait.
/// [HmErrorState]    what actually went wrong (no internet / too slow / server problem / other), a clear
///                   icon, and a Retry button. `compact` is the in-section version (a callout with Retry).
/// ============================================================
library;

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_feedback.dart';

/// Sits under a shimmer skeleton. Says nothing at first; on a slow connection it adds a calm hint, and after a long
/// wait a Try again button, so a bad connection never feels stuck. It is NOT a loader — the shimmer is the only
/// loading visual in the app.
class HmSlowLoadHint extends StatefulWidget {
  const HmSlowLoadHint({
    super.key,
    required this.hint,
    this.onRetry,
    this.slowAfter = const Duration(seconds: 8),
    this.retryAfter = const Duration(seconds: 20),
  });

  final String hint;

  /// Offered after [retryAfter].
  final VoidCallback? onRetry;
  final Duration slowAfter, retryAfter;

  @override
  State<HmSlowLoadHint> createState() => _HmSlowLoadHintState();
}

class _HmSlowLoadHintState extends State<HmSlowLoadHint> {
  Timer? _slowTimer, _retryTimer;
  bool _slow = false, _stuck = false;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(widget.slowAfter, () => mounted ? setState(() => _slow = true) : null);
    _retryTimer = Timer(widget.retryAfter, () => mounted ? setState(() => _stuck = true) : null);
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return AnimatedSize(
      duration: context.motion(HmMotion.normal),
      curve: HmMotion.curve,
      alignment: Alignment.topCenter,
      child: !_slow
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.hint, textAlign: TextAlign.center, style: TextStyle(color: c.ink2, fontSize: 13, height: 1.4)),
                  if (_stuck && widget.onRetry != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(onPressed: widget.onRetry, icon: const Icon(Icons.refresh_rounded, size: 18), label: Text(context.l.retry)),
                  ],
                ]),
              ),
            ),
    );
  }
}

/// How an error is shown: icon, title, message and the colours of its tile.
({IconData icon, String title, String body, bool connection}) describeError(BuildContext context, Object error) {
  final l = context.l;
  return switch (ApiException.from(error).kind) {
    ApiErrorKind.offline => (icon: Icons.wifi_off_rounded, title: l.errOfflineTitle, body: l.errOfflineBody, connection: true),
    ApiErrorKind.timeout => (icon: Icons.network_check_rounded, title: l.errTimeoutTitle, body: l.errTimeoutBody, connection: true),
    ApiErrorKind.server || ApiErrorKind.unauthorized => (icon: Icons.cloud_off_rounded, title: l.errServerTitle, body: l.errServerBody, connection: false),
    _ => (icon: Icons.error_outline_rounded, title: l.errUnknownTitle, body: l.errUnknownBody, connection: false),
  };
}

class HmErrorState extends StatelessWidget {
  const HmErrorState({super.key, required this.error, required this.onRetry, this.compact = false, this.retrying = false, this.footnote});
  final Object error;
  final VoidCallback onRetry;

  /// A retry is running: the button is disabled and says "Checking…" (no spinner — loading is shimmer only).
  final bool retrying;

  /// A quiet extra line under the message.
  final String? footnote;

  /// A callout with a Retry button, for inside a card / section. Default: a full-area screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final d = describeError(context, error);
    final code = ApiException.from(error).statusCode;
    final (bg, ink) = d.connection ? (c.am, c.amInk) : (c.dg, c.dgInk);

    if (compact) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Callout(
          d.connection ? CalloutKind.warn : CalloutKind.danger,
          icon: d.icon,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(d.body),
          ]),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded, size: 18), label: Text(l.retry)),
      ]);
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: '${d.title}. ${d.body}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 96, height: 96, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: bg.withValues(alpha: .55)),
              child: Container(
                width: 70, height: 70, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                child: ExcludeSemantics(child: Icon(d.icon, size: 34, color: ink)),
              ),
            ),
            const SizedBox(height: 20),
            Text(d.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(d.body, textAlign: TextAlign.center, style: TextStyle(color: c.ink2, height: 1.5)),
            if (code != null) ...[
              const SizedBox(height: 8),
              Text(l.errCode('$code'), style: TextStyle(color: c.ink3, fontSize: 12)),
            ],
            if (footnote != null) ...[
              const SizedBox(height: 10),
              Text(footnote!, textAlign: TextAlign.center, style: TextStyle(color: c.ink3, fontSize: 12.5, height: 1.45)),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: retrying ? null : onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retrying ? l.checkingConnection : l.retry),
            ),
          ]),
        ),
      ),
    );
  }
}

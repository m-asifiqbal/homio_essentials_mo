/// ============================================================
/// ARCHIVE GATE — shows the archive, a shimmer skeleton while it downloads, or a typed error with Retry
/// ============================================================
///
/// The archive is downloaded at every launch (and kept in memory only), so this is what the first seconds of
/// every screen look like. Loading is ALWAYS a shimmer skeleton — never a spinner or a progress bar — and on a
/// slow connection [ArchiveLoadHint] adds a calm message and, after a long wait, Try again.
/// ============================================================
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class ArchiveGate extends ConsumerWidget {
  const ArchiveGate({super.key, required this.builder, this.skeleton});
  final Widget Function(BuildContext context, Archive archive) builder;

  /// What shimmers while the archive downloads (default: a list of rows).
  final Widget? skeleton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(archiveProvider)) {
      AsyncValue(:final value?) => builder(context, value),
      AsyncError(:final error) => ArchiveError(error: error),
      _ => Stack(children: [
          // Not scrollable and clipped: a skeleton taller than the screen just runs off the bottom.
          Positioned.fill(
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: skeleton ?? const Padding(padding: EdgeInsets.only(top: 12), child: SkeletonList(count: 9)),
              ),
            ),
          ),
          const Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.only(bottom: 24), child: ArchiveLoadHint())),
        ]),
    };
  }
}

/// Under a skeleton: nothing at first, then "still loading — slow connection", then Try again.
class ArchiveLoadHint extends ConsumerWidget {
  const ArchiveLoadHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => HmSlowLoadHint(hint: context.l.loadingSlow, onRetry: () => ref.invalidate(archiveProvider));
}

/// Full-area error for a failed archive download.
class ArchiveError extends ConsumerWidget {
  const ArchiveError({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) => HmErrorState(error: error, onRetry: () => ref.invalidate(archiveProvider));
}

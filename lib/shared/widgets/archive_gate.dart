/// ============================================================
/// ARCHIVE GATE — shows the archive, a first-download state, or an error
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class ArchiveGate extends ConsumerWidget {
  const ArchiveGate({super.key, required this.builder, this.skeleton});
  final Widget Function(BuildContext context, Archive archive) builder;

  /// Shown while the archive downloads for the first time (default: logo + progress).
  final Widget? skeleton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(archiveProvider)) {
      AsyncValue(:final value?) => builder(context, value),
      AsyncError() => Center(
          child: EmptyState(
            icon: Icons.cloud_off_rounded, title: context.l.loadFailedTitle, body: context.l.loadFailedBody,
            action: context.l.retry, onAction: () => ref.invalidate(archiveProvider),
          ),
        ),
      _ => skeleton ??
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const HmLogo(size: 64),
              const SizedBox(height: 20),
              SizedBox(width: 160, child: LinearProgressIndicator(color: context.hm.p, backgroundColor: context.hm.sf3, minHeight: 6, borderRadius: BorderRadius.circular(9))),
              const SizedBox(height: 14),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(context.l.loadingArchive, textAlign: TextAlign.center, style: TextStyle(color: context.hm.ink2))),
            ]),
          ),
    };
  }
}

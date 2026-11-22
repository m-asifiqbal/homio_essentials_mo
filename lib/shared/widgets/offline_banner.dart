/// Thin amber banner when the last server check failed: what is already loaded stays usable, tap to retry.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateProvider);
    final offline = state == SyncState.offline;
    final c = context.hm;
    return AnimatedSize(
      duration: context.motion(HmMotion.normal),
      child: !offline
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Material(
                color: c.am,
                child: InkWell(
                  onTap: () => ref.read(archiveProvider.notifier).refresh(force: true),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(children: [
                        Icon(Icons.wifi_off_rounded, size: 16, color: c.amInk),
                        const SizedBox(width: 8),
                        Expanded(child: Text(context.l.offlineBanner, style: TextStyle(fontSize: 12.5, color: c.amInk, fontWeight: FontWeight.w600))),
                        Icon(Icons.refresh_rounded, size: 18, color: c.amInk),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

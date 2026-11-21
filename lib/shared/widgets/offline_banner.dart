/// Thin amber banner when the last update check failed but cached data is shown.
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
    final offline = ref.watch(syncStateProvider) == SyncState.offline;
    final c = context.hm;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      child: !offline
          ? const SizedBox(width: double.infinity)
          : Material(
              color: c.am,
              child: InkWell(
                onTap: () => ref.read(archiveProvider.notifier).refresh(),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(children: [
                      Icon(Icons.cloud_off_rounded, size: 16, color: c.amInk),
                      const SizedBox(width: 8),
                      Expanded(child: Text(context.l.offlineBanner, style: TextStyle(fontSize: 12.5, color: c.amInk, fontWeight: FontWeight.w600))),
                      Icon(Icons.refresh_rounded, size: 18, color: c.amInk),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }
}

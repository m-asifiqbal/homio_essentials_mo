/// Sources & review — where the text comes from, whether it was checked against the printed
/// book, when the archive was last updated, and a one-tap "report an error". MedEx shows
/// neither sources nor a date; this is the trust signal it lacks.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/features/requests/presentation/widgets/report_sheet.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class SourcesSection extends ConsumerWidget {
  const SourcesSection({super.key, required this.r});
  final Remedy r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final synced = ref.watch(archiveProvider.select((a) => a.value?.syncedAt));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final src in r.sourceRefs)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.menu_book_outlined, size: 20, color: c.pd),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${src['title'] ?? l.sourceBoericke}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                if (src['scan'] is Map && (src['scan'] as Map)['page'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(children: [
                      Icon(Icons.verified_outlined, size: 14, color: c.okInk),
                      const SizedBox(width: 4),
                      Expanded(child: Text(l.sourceChecked(numL(context, (src['scan'] as Map)['page'])), style: TextStyle(fontSize: 12, color: c.okInk))),
                    ]),
                  ),
                if (src['url'] is String)
                  GestureDetector(
                    onTap: () => openTarget('website', src['url'] as String),
                    child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.viewSource, style: TextStyle(fontSize: 12, color: c.p, fontWeight: FontWeight.w700))),
                  ),
              ]),
            ),
          ]),
        ),
      if (r.curated) Text(l.sourceCurated(AppInfo.localizedName(context.bn)), style: TextStyle(fontSize: 12, color: c.ink2, height: 1.5)),
      if (synced != null) ...[
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.update_rounded, size: 15, color: c.ink3),
          const SizedBox(width: 6),
          Expanded(child: Text(l.dataUpdated(numL(context, DateFormat.yMMMd(context.bn ? 'bn' : 'en').format(synced))), style: TextStyle(fontSize: 12, color: c.ink3))),
        ]),
      ],
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => showReportSheet(context, ref, entityType: 'remedy', entityId: r.id),
        icon: const Icon(Icons.flag_outlined, size: 18),
        label: Text(l.reportError),
      ),
    ]);
  }
}

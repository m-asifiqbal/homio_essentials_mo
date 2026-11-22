/// ============================================================
/// INFO SCREENS — Data & updates, Medical disclaimer, Sources, Potency guide
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/widgets/archive_gate.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final sync = ref.watch(syncStateProvider);
    final unreachable = sync == SyncState.offline;
    return Scaffold(
      appBar: AppBar(title: Text(l.dataTitle)),
      body: ArchiveGate(builder: (context, a) {
        final when = DateFormat.yMMMd(context.bn ? 'bn' : 'en').add_jm().format(a.syncedAt);
        final rels = a.relationsByRemedy.values.fold<int>(0, (n, x) => n + x.length);
        return ListView(padding: const EdgeInsets.all(20), children: [
          HmCard(
            child: Row(children: [
              Icon(unreachable ? Icons.wifi_off_rounded : Icons.cloud_done_outlined, color: unreachable ? c.amInk : c.okInk, size: 28),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sync == SyncState.syncing ? l.updating : unreachable ? l.dataUnreachable : l.dataLoadedAt(when), style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(l.dataLive, style: TextStyle(fontSize: 13, color: c.ink2)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: sync == SyncState.syncing ? null : () => ref.read(archiveProvider.notifier).refresh(force: true),
            icon: const Icon(Icons.sync_rounded),
            label: Text(l.checkUpdates),
          ),
          const SizedBox(height: 24),
          Cap(l.inThisArchive),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.9,
            children: [
              for (final (label, n) in [(l.statRemedies, a.remedies.length), (l.statSymptoms, a.conditions.length), (l.statRelations, rels), (l.statCompanies, a.manufacturers.length)])
                HmCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(numL(context, n), style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: c.pd)),
                  Text(label, style: TextStyle(fontSize: 13, color: c.ink2)),
                ])),
            ],
          ),
          const SizedBox(height: 16),
          Callout(CalloutKind.note, child: Text(l.dataNote)),
        ]);
      }),
    );
  }
}

class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final a = ref.watch(archiveProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.disclaimerTitle)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        SelectableText(a?.configText('disclaimer', context.bn) ?? l.disclaimerFallback, style: const TextStyle(fontSize: 16, height: 1.7)),
        const SizedBox(height: 20),
        Callout(CalloutKind.note, child: Text(l.sourceCurated(AppInfo.localizedName(context.bn)))),
      ]),
    );
  }
}

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    const items = [
      ('W. Boericke — Pocket Manual of Homoeopathic Materia Medica', '9th ed., 1927 · public domain', 'https://www.materiamedica.info/en/materia-medica/william-boericke/index'),
      ('W. Boericke — 8th ed. (1922), scanned copy', 'Used to check the text word by word', 'https://archive.org/details/in.ernet.dli.2015.125811'),
      ('H. C. Allen — Keynotes and Characteristics with Comparisons', '1898 · public domain', 'https://www.materiamedica.info/en/materia-medica/henry-c-allen/index'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.sourcesCredits)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final (t, s, url) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HmCard(
              onTap: () => openTarget('website', url),
              child: Row(children: [
                Icon(Icons.menu_book_outlined, color: c.pd),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(s, style: TextStyle(fontSize: 13, color: c.ink2)),
                ])),
                Icon(Icons.open_in_new_rounded, size: 18, color: c.ink3),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        Text(l.studyFooter, style: TextStyle(fontSize: 13, color: c.ink2, height: 1.6)),
        const SizedBox(height: 12),
        Text(l.sourceCurated(AppInfo.localizedName(context.bn)), style: TextStyle(fontSize: 13, color: c.ink2, height: 1.6)),
      ]),
    );
  }
}

class PotencyGuideScreen extends StatelessWidget {
  const PotencyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.guideTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        HeroBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HmBadge(l.guideBadge, glass: true),
          const SizedBox(height: 10),
          Text(l.potencyGuideTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, height: 1.25)),
        ])),
        const SizedBox(height: 20),
        for (final (t, b) in [(l.guideP1T, l.guideP1), (l.guideP2T, l.guideP2), (l.guideP3T, l.guideP3), (l.guideP4T, l.guideP4)]) ...[
          Semantics(header: true, child: Text(t, style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 6),
          Text(b, style: TextStyle(fontSize: 15, height: 1.65, color: c.ink)),
          const SizedBox(height: 20),
        ],
        Callout(CalloutKind.warn, child: Text(l.guideNote)),
      ]),
    );
  }
}

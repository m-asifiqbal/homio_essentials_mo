/// MY REQUESTS — status of what this device sent (no account needed).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/requests/presentation/providers/requests_providers.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.myRequests)),
      body: switch (ref.watch(myRequestsProvider)) {
        AsyncValue(:final value?) when value.isEmpty =>
          EmptyState(icon: Icons.assignment_outlined, title: l.myRequestsEmpty, action: l.requestMedicine, onAction: () => context.push(AppRoutes.request)),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(myRequestsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = value[i];
                final (bg, ink) = switch (r.status) {
                  'approved' || 'merged' => (c.ok, c.okInk),
                  'rejected' => (c.dg, c.dgInk),
                  'needs_info' => (c.miBg, c.miInk),
                  _ => (c.am, c.amInk),
                };
                return HmCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(r.title ?? r.code, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                      HmBadge(l.status(r.status), bg: bg, ink: ink),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      [r.code, r.kind == 'product' ? l.kindProductLabel : l.kindRemedyLabel, if (r.createdAt != null) DateFormat.yMMMd(context.bn ? 'bn' : 'en').format(r.createdAt!.toLocal())]
                          .join(' · '),
                      style: TextStyle(fontSize: 12.5, color: c.ink2),
                    ),
                    if (r.note != null) ...[const SizedBox(height: 8), Callout(CalloutKind.note, child: Text(r.note!))],
                  ]),
                );
              },
            ),
          ),
        AsyncError() => EmptyState(icon: Icons.cloud_off_rounded, title: l.sendFailed, action: l.retry, onAction: () => ref.invalidate(myRequestsProvider)),
        _ => const SkeletonList(count: 3),
      },
    );
  }
}

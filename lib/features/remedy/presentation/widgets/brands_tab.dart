/// BRANDS TAB — verified products and prices (none yet → suggest a brand).
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';

class BrandsTab extends StatelessWidget {
  const BrandsTab({super.key, required this.d});
  final RemedyDetail d;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    if (d.products.isEmpty) {
      return TabList(name: 'brands', children: [
        EmptyState(
          icon: Icons.sell_outlined, title: l.brandsEmptyTitle, body: l.brandsEmptyBody, action: l.suggestBrand,
          onAction: () => context.push(AppRoutes.requestFor(kind: 'product', name: d.remedy.latin)),
        ),
      ]);
    }
    return TabList(name: 'brands', children: [
      for (final p in d.products)
        Gutter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HmCard(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                      [d.manufacturerNames[p.manufacturerId], p.potency, p.form.replaceAll('_', ' '), if (p.packSize != null) '${p.packSize!.toStringAsFixed(0)} ${p.packUnit ?? ''}']
                          .whereType<String>().join(' · '),
                      style: TextStyle(fontSize: 13, color: c.ink2),
                    ),
                  ]),
                ),
                if (p.price != null) Text('৳${numL(context, p.price!.toStringAsFixed(0))}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
    ]);
  }
}

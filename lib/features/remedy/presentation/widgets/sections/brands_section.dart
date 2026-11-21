/// Available brands — verified products with company, strength, pack and price
/// (MedEx's "Available Brand Names" cards), sortable by price. None yet → suggest a brand.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

class BrandsSection extends StatefulWidget {
  const BrandsSection({super.key, required this.d});
  final RemedyDetail d;

  @override
  State<BrandsSection> createState() => _BrandsSectionState();
}

class _BrandsSectionState extends State<BrandsSection> {
  bool _byPrice = false;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final d = widget.d;
    if (d.products.isEmpty) {
      return Column(children: [
        Text(l.brandsEmptyBody, style: TextStyle(fontSize: 13.5, color: c.ink2, height: 1.55)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => context.push(AppRoutes.requestFor(kind: 'product', name: d.remedy.latin)), child: Text(l.suggestBrand)),
      ]);
    }
    final products = [...d.products];
    if (_byPrice) products.sort((a, b) => (a.price ?? double.infinity).compareTo(b.price ?? double.infinity));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(l.brandsCount(numL(context, products.length)), style: TextStyle(fontSize: 12.5, color: c.ink2, fontWeight: FontWeight.w600))),
        HmChip(l.sortByPrice, small: true, icon: Icons.swap_vert_rounded, selected: _byPrice, onTap: () => setState(() => _byPrice = !_byPrice)),
      ]),
      const SizedBox(height: 10),
      for (final p in products) Padding(padding: const EdgeInsets.only(bottom: 8), child: _BrandCard(p: p, company: d.manufacturerNames[p.manufacturerId])),
      Text(l.brandsNote, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.5)),
    ]);
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.p, required this.company});
  final Product p;
  final String? company;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final mono = (company ?? p.name).replaceAll(RegExp(r'[^A-Za-z]'), '');
    return HmCard(
      elevated: false,
      color: c.bg,
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(color: c.miBg, borderRadius: BorderRadius.circular(12)),
          child: Text(mono.length >= 2 ? mono.substring(0, 2).toUpperCase() : mono.toUpperCase(), style: TextStyle(color: c.miInk, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (company != null) Text(company!, style: TextStyle(fontSize: 12, color: c.ink2)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (p.potency != null) HmBadge(p.potency!),
              HmBadge(p.form.replaceAll('_', ' '), bg: c.sf2, ink: c.ink2),
              if (p.packSize != null) HmBadge('${p.packSize!.toStringAsFixed(0)} ${p.packUnit ?? ''}'.trim(), bg: c.sf2, ink: c.ink2),
            ]),
          ]),
        ),
        if (p.price != null) ...[
          const SizedBox(width: 10),
          Text('৳${numL(context, p.price!.toStringAsFixed(0))}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}

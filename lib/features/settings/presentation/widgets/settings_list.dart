/// Grouped list card used by Settings (icon tile · title · subtitle · chevron).
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class SettingsItem {
  const SettingsItem(this.icon, this.tone, this.title, this.sub, this.onTap, {this.logo = false});
  final IconData? icon;
  final (Color, Color) tone;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final bool logo;
}

class SettingsGroupLabel extends StatelessWidget {
  const SettingsGroupLabel(this.title, {super.key, this.first = false});
  final String title;
  final bool first;

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(16, first ? 6 : 24, 16, 10), child: Semantics(header: true, child: Cap(title)));
}

class SettingsList extends StatelessWidget {
  const SettingsList({super.key, required this.items});
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return HmCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (final (i, it) in items.indexed) ...[
          if (i > 0) Divider(color: c.ln),
          InkWell(
            onTap: it.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 58),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(children: [
                  if (it.logo) const SizedBox(width: 40, height: 40, child: Center(child: HmLogo(size: 32))) else IconTile(it.icon ?? Icons.circle_outlined, it.tone),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    if (it.sub != null) Text(it.sub!, style: TextStyle(fontSize: 12, color: c.ink2)),
                  ])),
                  if (it.onTap != null) Icon(Icons.chevron_right_rounded, color: c.ink3),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

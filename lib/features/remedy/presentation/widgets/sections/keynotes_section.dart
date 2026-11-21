/// Keynotes section — Allen's characteristic symptoms as short bullets.
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

class KeynotesSection extends StatelessWidget {
  const KeynotesSection({super.key, required this.notes});
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final k in notes)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(margin: const EdgeInsets.only(top: 7), width: 6, height: 6, decoration: BoxDecoration(color: c.p2, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(child: SelectableText(k, style: const TextStyle(fontSize: 13.5, height: 1.55))),
          ]),
        ),
      Text(context.l.keynotesSource, style: TextStyle(fontSize: 11.5, color: c.ink3)),
    ]);
  }
}

/// Keynotes section — Allen's characteristic symptoms as short bullets (or an empty state).
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class KeynotesSection extends StatelessWidget {
  const KeynotesSection({super.key, required this.notes, required this.goSection, this.autoTranslated = false});
  final List<String> notes;
  final ValueChanged<String> goSection;

  /// The notes are an automatic Bangla translation of Allen's English.
  final bool autoTranslated;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    if (notes.isEmpty) {
      return SectionEmpty(icon: Icons.key_rounded, title: l.keynotesEmptyTitle, body: l.keynotesEmptyBody, action: l.openMateria, onAction: () => goSection('materia'));
    }
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
      Text(l.keynotesSource, style: TextStyle(fontSize: 11.5, color: c.ink3)),
      if (autoTranslated) Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.autoTranslatedNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
    ]);
  }
}

/// ============================================================
/// HM TEXT — Latin remedy names and highlighted search matches
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

Text latinText(String s, {double size = 17, Color? color, FontWeight weight = FontWeight.w500, int? maxLines}) =>
    Text(s, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis, style: latinStyle(size: size, color: color, weight: weight));

/// Bolds every occurrence of [query]'s words inside [text] (case-insensitive), like the design's `<mark>`.
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.text, this.query, {super.key, this.style, this.maxLines = 1});
  final String text, query;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final words = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
    if (words.isEmpty) return Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: base);
    final lower = text.toLowerCase();
    final marks = List<bool>.filled(text.length, false);
    for (final w in words) {
      for (var i = lower.indexOf(w); i >= 0; i = lower.indexOf(w, i + w.length)) {
        for (var j = i; j < i + w.length && j < marks.length; j++) {
          marks[j] = true;
        }
      }
    }
    final spans = <TextSpan>[];
    var start = 0;
    for (var i = 1; i <= text.length; i++) {
      if (i == text.length || marks[i] != marks[start]) {
        spans.add(TextSpan(
          text: text.substring(start, i),
          style: marks[start] ? TextStyle(color: context.hm.p, fontWeight: FontWeight.w700) : null,
        ));
        start = i;
      }
    }
    return Text.rich(TextSpan(style: base, children: spans), maxLines: maxLines, overflow: TextOverflow.ellipsis);
  }
}

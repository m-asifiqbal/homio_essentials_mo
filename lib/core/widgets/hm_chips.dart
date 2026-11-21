/// ============================================================
/// HM CHIPS — chips, chip rows, segmented control, badges, letter tiles
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_pressable.dart';

class HmChip extends StatelessWidget {
  const HmChip(this.label, {super.key, this.selected = false, this.onTap, this.dot, this.small = false, this.icon, this.onDelete, this.count});
  final String label;
  final bool selected, small;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? dot;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final fg = selected ? c.onp : c.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: HmPressable(
        onTap: onTap == null ? null : () { HapticFeedback.selectionClick(); onTap!(); },
        scale: 0.96,
        child: AnimatedContainer(
            duration: context.motion(HmMotion.fast),
            curve: HmMotion.curve,
            height: small ? 34 : 40,
            padding: EdgeInsetsDirectional.only(start: small ? 12 : 16, end: onDelete != null ? 4 : (small ? 12 : 16)),
            decoration: ShapeDecoration(color: selected ? c.p : c.sf, shape: StadiumBorder(side: BorderSide(color: selected ? c.p : c.ln))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (dot != null) ...[Container(width: 8, height: 8, decoration: BoxDecoration(color: selected ? c.onp : dot, shape: BoxShape.circle)), const SizedBox(width: 6)],
              if (icon != null) ...[Icon(icon, size: 16, color: selected ? c.onp : c.ink2), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontSize: small ? 12.5 : 13.5, fontWeight: FontWeight.w600, color: fg)),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: selected ? c.onp.withValues(alpha: .22) : c.sf2, borderRadius: BorderRadius.circular(99)),
                  child: Text(numL(context, count!), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: selected ? c.onp : c.pd)),
                ),
              ],
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete, tooltip: context.l.remove, visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 16, color: selected ? c.onp : c.ink3),
                ),
            ]),
        ),
      ),
    );
  }
}

/// Horizontally scrolling chip row with the page gutter.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Hm.gutter),
        child: Row(children: [for (final (i, w) in children.indexed) Padding(padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 8), child: w)]),
      );
}

class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value, required this.onChanged});
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// A white thumb SLIDES to the chosen option (FocusFlow-style) instead of each option blinking.
  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final n = options.length;
    final index = options.indexWhere((o) => o.$1 == value).clamp(0, n - 1);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 38,
        child: Stack(children: [
          AnimatedAlign(
            duration: context.motion(HmMotion.normal),
            curve: HmMotion.curve,
            alignment: Alignment(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 4, offset: const Offset(0, 1))]),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Row(children: [
            for (final (v, label) in options)
              Expanded(
                child: Semantics(
                  button: true, selected: v == value, label: label,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () { if (v != value) HapticFeedback.selectionClick(); onChanged(v); },
                    child: Center(
                      child: ExcludeSemantics(
                        child: AnimatedDefaultTextStyle(
                          duration: context.motion(HmMotion.fast),
                          style: TextStyle(fontSize: 13.5, fontWeight: v == value ? FontWeight.w700 : FontWeight.w600, color: v == value ? c.pd : c.ink2),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          child: Text(label),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

class HmBadge extends StatelessWidget {
  const HmBadge(this.label, {super.key, this.bg, this.ink, this.icon, this.glass = false});
  final String label;
  final Color? bg, ink;
  final IconData? icon;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final fg = glass ? Colors.white : (ink ?? c.pd);
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: glass ? Colors.white.withValues(alpha: .18) : (bg ?? c.sf2), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg))),
      ]),
    );
  }
}

class KingdomBadge extends StatelessWidget {
  const KingdomBadge(this.kingdom, {super.key, this.glass = false, this.extra});
  final String? kingdom;
  final bool glass;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final (bg, ink) = context.hm.kingdom(kingdom);
    return HmBadge([context.l.kingdom(kingdom), ?extra].join(' · '), bg: bg, ink: ink, glass: glass, icon: kingdomIcon(kingdom));
  }
}

IconData kingdomIcon(String? k) => switch (k) {
      'plant' => Icons.eco_outlined,
      'mineral' => Icons.diamond_outlined,
      'animal' => Icons.pets_outlined,
      'nosode' => Icons.biotech_outlined,
      'sarcode' => Icons.favorite_border,
      'imponderabilia' => Icons.bolt_outlined,
      _ => Icons.science_outlined,
    };

/// Rounded "monogram" tile tinted by kingdom (design: `.tile`).
class LetterTile extends StatelessWidget {
  const LetterTile(this.letter, {super.key, this.kingdom, this.size = 48, this.icon});
  final String letter;
  final String? kingdom;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, ink) = context.hm.kingdom(kingdom);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.29)),
      alignment: Alignment.center,
      child: icon != null ? Icon(icon, color: ink, size: size * 0.5) : Text(letter, style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: size * 0.4)),
    );
  }
}

/// Square icon tile in a tone pair (bg, ink).
class IconTile extends StatelessWidget {
  const IconTile(this.icon, this.tone, {super.key, this.size = 40});
  final IconData icon;
  final (Color, Color) tone;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: tone.$1, borderRadius: BorderRadius.circular(size * .3)),
        child: Icon(icon, color: tone.$2, size: size * .5),
      );
}

/// ============================================================
/// HM CARD — bordered surface card and the teal gradient hero box
/// ============================================================
///
/// Tap feedback is the design system's press-scale ([HmPressable]), not a
/// Material ripple. Cards are one painted DecoratedBox — cheap to scroll.
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_pressable.dart';

class HmCard extends StatelessWidget {
  const HmCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color, this.border, this.radius = Hm.rCard, this.semanticLabel, this.elevated = true});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? border;
  final double radius;
  final String? semanticLabel;

  /// A very soft lift (see [HomaColors.cardShadow]). Turn off for a card nested inside another card.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.sf,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? c.ln, width: border == null ? 1 : 2),
        boxShadow: elevated ? c.cardShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: onTap == null ? card : HmPressable(onTap: onTap, child: card),
    );
  }
}

/// Teal gradient panel with a soft circle, used for heroes and the dose card.
class HeroBox extends StatelessWidget {
  const HeroBox({super.key, required this.child, this.radius = 28, this.padding = const EdgeInsets.all(20), this.onTap});
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final box = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: c.heroGradient),
        child: Stack(children: [
          PositionedDirectional(end: -50, top: -60, child: heroCircle(200)),
          Padding(padding: padding, child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child)),
        ]),
      ),
    );
    return Semantics(button: onTap != null, child: onTap == null ? box : HmPressable(onTap: onTap, scale: 0.985, child: box));
  }
}

Widget heroCircle(double d, {double alpha = .08}) =>
    RepaintBoundary(child: Container(width: d, height: d, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha))));

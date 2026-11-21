/// ============================================================
/// HM CARD — bordered surface card and the teal gradient hero box
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

class HmCard extends StatelessWidget {
  const HmCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color, this.border, this.radius = Hm.rCard, this.semanticLabel});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? border;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: color ?? c.sf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: border ?? c.ln, width: border == null ? 1 : 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(gradient: c.heroGradient),
          child: InkWell(
            onTap: onTap,
            child: Stack(children: [
              PositionedDirectional(end: -50, top: -60, child: heroCircle(200)),
              Padding(padding: padding, child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child)),
            ]),
          ),
        ),
      ),
    );
  }
}

Widget heroCircle(double d, {double alpha = .08}) =>
    Container(width: d, height: d, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)));

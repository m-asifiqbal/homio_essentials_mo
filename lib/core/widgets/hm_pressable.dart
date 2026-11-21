/// ============================================================
/// HM PRESSABLE — press-scale feedback + staggered reveal
/// ============================================================
///
/// The design system's tap feedback for cards and tiles is a gentle scale to
/// [HmMotion.pressScale] (FocusFlow's `FFPressable`) — no Material ripple on
/// cards. Under reduce motion the scale is dropped entirely.
///
/// [HmReveal] fades + slides a child in the first time it is built, with an
/// optional [index] stagger — used for list rows and Home sections.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

class HmPressable extends StatefulWidget {
  const HmPressable({super.key, required this.child, this.onTap, this.onLongPress, this.scale = HmMotion.pressScale, this.haptic = false, this.behavior = HitTestBehavior.opaque});
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale while pressed (1 = no effect).
  final double scale;

  /// A soft selection tick on tap.
  final bool haptic;
  final HitTestBehavior behavior;

  @override
  State<HmPressable> createState() => _HmPressableState();
}

class _HmPressableState extends State<HmPressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    final pressed = _down && !context.reduceMotion;
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(scale: pressed ? widget.scale : 1, duration: HmMotion.fast, curve: HmMotion.curve, child: widget.child),
    );
  }
}

/// Fade + 14 px rise, once, when first built. [index] staggers siblings by 45 ms (capped).
///
/// [once] makes the reveal play only the FIRST time that key is built in this app run: a list
/// that recycles the widget (scrolling away and back) must not replay the animation — that
/// read as the screen "rendering again and again".
class HmReveal extends StatefulWidget {
  const HmReveal({super.key, required this.child, this.index = 0, this.dy = 14, this.once});
  final Widget child;
  final int index;
  final double dy;
  final String? once;

  static final _done = <String>{};

  @override
  State<HmReveal> createState() => _HmRevealState();
}

class _HmRevealState extends State<HmReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: HmMotion.curve);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final seen = widget.once != null && !HmReveal._done.add(widget.once!);
    if (context.reduceMotion || seen) {
      _c.value = 1;
    } else {
      Future.delayed(Duration(milliseconds: 45 * widget.index.clamp(0, 8)), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) => Opacity(
          opacity: _t.value,
          child: Transform.translate(offset: Offset(0, widget.dy * (1 - _t.value)), child: child),
        ),
      );
}

/// ============================================================
/// HM DIALOG — centred rounded dialog, ported from FocusFlow's FFDialog
/// ============================================================
///
/// * [HmDialog]      ringed icon · title · message · stacked full-width actions (30 dp radius, max 340 dp wide)
/// * [showHmDialog]  fade + 0.94→1 scale-in route with a scrim and a soft σ 3 backdrop blur
/// * [showHmConfirm] two-choice confirmation → true only on confirm (primary button + muted text action)
///
/// Same look as FocusFlow's dialogs, in Homio's teal tokens. Use it for every confirmation (exit, discard…).
/// ============================================================
library;

import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

/// Backdrop blur sigma behind a dialog.
const double kHmBackdropBlur = 3;

/// Pushes [builder] as a centred dialog (fade + 0.94→1 scale) on the root navigator.
Future<T?> showHmDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final dark = Theme.of(context).brightness == Brightness.dark;
  return navigator.push<T>(_HmDialogRoute<T>(
    barrierDismissible: barrierDismissible,
    barrierColor: dark ? const Color(0xFF000000).withValues(alpha: .55) : const Color(0xFF062B2C).withValues(alpha: .45),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: context.motion(HmMotion.normal),
    pageBuilder: (ctx, _, _) => themes.wrap(Builder(builder: builder)),
    transitionBuilder: (ctx, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: HmMotion.curve);
      return FadeTransition(opacity: curved, child: ScaleTransition(scale: Tween<double>(begin: .94, end: 1).animate(curved), child: child));
    },
  ));
}

class _HmDialogRoute<T> extends RawDialogRoute<T> {
  _HmDialogRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.transitionDuration,
    super.transitionBuilder,
  });

  /// The stock barrier, blurred a little more as the dialog fades in.
  @override
  Widget buildModalBarrier() {
    final barrier = super.buildModalBarrier();
    final a = animation;
    if (a == null) return BackdropFilter(filter: ImageFilter.blur(sigmaX: kHmBackdropBlur, sigmaY: kHmBackdropBlur), child: barrier);
    return AnimatedBuilder(
      animation: a,
      builder: (context, child) {
        final sigma = kHmBackdropBlur * a.value.clamp(0.0, 1.0);
        return BackdropFilter(filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), child: child);
      },
      child: barrier,
    );
  }
}

class HmDialog extends StatelessWidget {
  const HmDialog({super.key, this.icon, this.iconColor, this.iconBackground, this.title, this.message, this.actions = const []});

  final IconData? icon;

  /// Icon colour (default: the primary teal).
  final Color? iconColor;

  /// Ring fill (default: the icon colour at 12%).
  final Color? iconBackground;
  final String? title;
  final String? message;

  /// Stacked full-width buttons, 10 dp apart.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final media = MediaQuery.of(context);
    final accent = iconColor ?? c.p;
    final ring = iconBackground ?? accent.withValues(alpha: .12);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Material(
                color: c.sf,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: c.ln)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 22, 24, 12),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (icon != null) ...[
                      Center(child: _RingedIcon(icon: icon!, color: accent, fill: ring)),
                      const SizedBox(height: 16),
                    ],
                    if (title != null) Semantics(header: true, child: Text(title!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
                    if (message != null) ...[
                      const SizedBox(height: 10),
                      Text(message!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5, height: 1.5, color: c.ink2)),
                    ],
                    if (actions.isNotEmpty) const SizedBox(height: 22),
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      actions[i],
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingedIcon extends StatelessWidget {
  const _RingedIcon({required this.icon, required this.color, required this.fill});
  final IconData icon;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) => Container(
        width: 80, height: 80, alignment: Alignment.center,
        decoration: BoxDecoration(color: fill.withValues(alpha: fill.a * .45), shape: BoxShape.circle),
        child: Container(
          width: 64, height: 64, alignment: Alignment.center,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
          child: ExcludeSemantics(child: Icon(icon, size: 26, color: color)),
        ),
      );
}

/// Generic two-choice confirmation. Returns true only on confirm (barrier tap / back = cancel).
Future<bool> showHmConfirm(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final l = context.l;
  final result = await showHmDialog<bool>(
    context,
    builder: (ctx) {
      final c = ctx.hm;
      return HmDialog(
        icon: icon,
        iconColor: destructive ? c.dgInk : c.p,
        iconBackground: destructive ? c.dg : c.p.withValues(alpha: .12),
        title: title,
        message: message,
        actions: [
          FilledButton(
            style: destructive ? FilledButton.styleFrom(backgroundColor: c.dgInk, foregroundColor: Colors.white) : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
          // Muted text action under the button, like FocusFlow's dialogs.
          TextButton(
            style: TextButton.styleFrom(foregroundColor: c.ink2, minimumSize: const Size.fromHeight(44), textStyle: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel ?? l.cancel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

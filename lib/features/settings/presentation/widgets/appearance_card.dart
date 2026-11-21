/// ============================================================
/// APPEARANCE — theme picker (Light · Dark · System previews), accent swatches, text size
/// ============================================================
///
/// Same design strategy as FocusFlow's Settings › Appearance: instead of a single
/// day/night toggle, three miniature phone screens drawn from the real light / dark
/// token sets (so they follow the chosen accent); the selected one gets an accent ring,
/// an accent label and a check. System is half light, half dark. Below: round accent
/// swatches with a ring, and a text-size slider with a live preview and size chip.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_text_scaler.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

// ───────────────────────────── Theme picker ─────────────────────────────

class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    return HmCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (i, mode) in DayNight.values.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ThemeOption(
              mode: mode,
              accent: s.accent,
              selected: s.dayNight == mode,
              onTap: () {
                HapticFeedback.selectionClick();
                ctl.setDayNight(mode);
              },
            ),
          ),
        ],
      ]),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.accent, required this.selected, required this.onTap});
  final DayNight mode;
  final String accent;
  final bool selected;
  final VoidCallback onTap;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final light = HomaColors.of(dark: false, accent: accent);
    final dark = HomaColors.of(dark: true, accent: accent);
    final label = switch (mode) { DayNight.day => l.themeLight, DayNight.night => l.themeDark, DayNight.system => l.themeSystem };
    final preview = switch (mode) {
      DayNight.day => _PhonePreview(colors: light),
      DayNight.night => _PhonePreview(colors: dark),
      DayNight.system => Stack(fit: StackFit.passthrough, children: [
          _PhonePreview(colors: light),
          Positioned.fill(child: ClipRect(clipper: const _EndHalf(), child: _PhonePreview(colors: dark))),
        ]),
    };
    return Semantics(
      button: true,
      selected: selected,
      label: l.themeOptionLabel(label),
      excludeSemantics: true,
      child: HmPressable(
        onTap: onTap,
        child: Column(children: [
          AspectRatio(
            aspectRatio: 100 / 152,
            child: AnimatedContainer(
              duration: context.motion(HmMotion.fast),
              curve: HmMotion.curve,
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius + 2),
                border: Border.all(color: selected ? c.p : c.ln, width: selected ? 2.25 : 1.25),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(selected ? _radius - 3 : _radius), child: preview),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? c.p : c.ink)),
          const SizedBox(height: 8),
          _CheckDot(checked: selected),
        ]),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return AnimatedContainer(
      duration: context.motion(HmMotion.fast),
      width: 20, height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? c.p : Colors.transparent,
        border: Border.all(color: checked ? c.p : c.ink3, width: 1.5),
      ),
      child: AnimatedScale(
        duration: context.motion(HmMotion.fast),
        curve: Curves.easeOutBack,
        scale: checked ? 1 : 0,
        child: Icon(Icons.check_rounded, size: 14, color: c.onp),
      ),
    );
  }
}

/// Keeps the end half (the right half in LTR) of the child.
class _EndHalf extends CustomClipper<Rect> {
  const _EndHalf();

  @override
  Rect getClip(Size size) => Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_EndHalf oldClipper) => false;
}

/// A tiny Home screen: title bar · hero card · two rows.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.colors});
  final HomaColors colors;

  @override
  Widget build(BuildContext context) {
    final row = colors.dark ? colors.sf2 : colors.sf;
    return ColoredBox(
      color: colors.bg,
      child: LayoutBuilder(builder: (context, box) {
        final u = box.maxWidth / 100; // 1 unit ≈ 1 pt at the mockup size
        return Padding(
          padding: EdgeInsets.fromLTRB(11 * u, 11 * u, 11 * u, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40 * u, height: 7 * u, decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(4 * u))),
            SizedBox(height: 10 * u),
            Container(height: 40 * u, decoration: BoxDecoration(gradient: colors.heroGradient, borderRadius: BorderRadius.circular(10 * u))),
            for (var i = 0; i < 2; i++) ...[
              SizedBox(height: 7 * u),
              Container(height: 23 * u, decoration: BoxDecoration(color: row, borderRadius: BorderRadius.circular(8 * u), border: Border.all(color: colors.ln, width: .5))),
            ],
          ]),
        );
      }),
    );
  }
}

// ───────────────────────────── Accent picker ─────────────────────────────

class AccentPicker extends ConsumerWidget {
  const AccentPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    return HmCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        for (final (id, c1, c2) in HomaColors.accents)
          Semantics(
            button: true,
            selected: s.accent == id,
            label: l.accent(id),
            excludeSemantics: true,
            child: HmPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                ctl.setAccent(id);
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: context.motion(HmMotion.fast),
                  curve: HmMotion.curve,
                  width: 50, height: 50,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: s.accent == id ? c.p : Colors.transparent, width: 2.25)),
                  child: DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: AnimatedScale(
                      duration: context.motion(HmMotion.fast),
                      curve: Curves.easeOutBack,
                      scale: s.accent == id ? 1 : 0,
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l.accent(id), style: TextStyle(fontSize: 12, fontWeight: s.accent == id ? FontWeight.w700 : FontWeight.w500, color: s.accent == id ? c.ink : c.ink2)),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ───────────────────────────── Text size ─────────────────────────────

class TextSizeCard extends ConsumerStatefulWidget {
  const TextSizeCard({super.key});

  @override
  ConsumerState<TextSizeCard> createState() => _TextSizeCardState();
}

class _TextSizeCardState extends ConsumerState<TextSizeCard> {
  /// Stop under the thumb while dragging (null when idle) — only the preview re-scales
  /// during the drag; the setting is saved once, when the gesture ends.
  int? _drag;

  String _name(BuildContext context, double scale) {
    final l = context.l;
    const base = AppSettings.defaultTextScale;
    if ((scale - base).abs() < 0.001) return l.textDefault;
    if (scale < base) return scale < 0.875 ? l.textSmaller : l.textSmall;
    if (scale < 1.1) return l.textLarge;
    return scale < 1.2 ? l.textLarger : l.textLargest;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final s = ref.watch(settingsProvider);
    final stops = AppSettings.textScaleStops;
    final saved = s.textScaleIndex;
    final shown = _drag ?? saved;
    final scale = stops[shown];
    final preview = Text(l.textPreview, style: TextStyle(fontSize: 14.5, height: 1.5, color: c.ink2));
    return HmCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: Text(l.textSize, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5))),
          const Spacer(),
          AnimatedSwitcher(
            duration: context.motion(HmMotion.fast),
            transitionBuilder: (child, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween<double>(begin: .85, end: 1).animate(a), child: child)),
            child: Container(
              key: ValueKey(shown),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(99)),
              child: Text('${_name(context, scale)} · ${numL(context, (scale * 100).round())}%', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.pd)),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const ExcludeSemantics(child: Text('A', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(
            child: Slider(
              value: shown.toDouble(),
              max: (stops.length - 1).toDouble(),
              divisions: stops.length - 1,
              label: '${(scale * 100).round()}%',
              semanticFormatterCallback: (v) => '${l.textSize} ${_name(context, stops[v.round()])}',
              onChanged: (v) => setState(() => _drag = v.round()),
              onChangeEnd: (v) {
                ref.read(settingsProvider.notifier).setTextScale(stops[v.round()]);
                setState(() => _drag = null);
              },
            ),
          ),
          const ExcludeSemantics(child: Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 4),
        if (_drag == null || _drag == saved)
          preview
        else
          // The app already applies the saved stop; scale the preview by the ratio to show the stop under the thumb.
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: AppTextScaler.compose(MediaQuery.textScalerOf(context), stops[_drag!] / stops[saved])),
            child: preview,
          ),
      ]),
    );
  }
}

/// A settings row with a label, a sub-line and an iOS-style switch.
class SwitchRow extends StatelessWidget {
  const SwitchRow({super.key, required this.icon, required this.tone, required this.title, required this.sub, required this.value, required this.onChanged});
  final IconData icon;
  final (Color, Color) tone;
  final String title, sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return HmCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      child: Row(children: [
        IconTile(icon, tone),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
            Text(sub, style: TextStyle(fontSize: 12, color: c.ink2, height: 1.35)),
          ]),
        ),
        const SizedBox(width: 8),
        HmSwitch(value: value, onChanged: onChanged, semanticLabel: title),
      ]),
    );
  }
}

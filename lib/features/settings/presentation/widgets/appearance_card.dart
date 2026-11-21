/// ============================================================
/// APPEARANCE CARD — day/night switch, match phone, accent swatches, preview
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final night = s.dayNight == DayNight.night || (s.dayNight == DayNight.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return HmCard(
      radius: 24, padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(night ? l.nightMode : l.dayMode, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(s.dayNight == DayNight.system ? l.systemSub : (night ? l.nightSub : l.daySub), style: TextStyle(fontSize: 13, color: c.ink2)),
            ])),
            DayNightSwitch(night: night, onChanged: (v) => ctl.setDayNight(v ? DayNight.night : DayNight.day)),
          ]),
        ),
        Divider(color: c.ln),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          secondary: Icon(Icons.smartphone_rounded, color: c.pd),
          title: Text(l.matchPhone, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text(l.matchPhoneSub, style: TextStyle(fontSize: 12.5, color: c.ink2)),
          value: s.dayNight == DayNight.system,
          onChanged: (v) => ctl.setDayNight(v ? DayNight.system : (night ? DayNight.night : DayNight.day)),
        ),
        Divider(color: c.ln),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.themeColour, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final (id, c1, c2) in HomaColors.accents)
                Semantics(
                  button: true, selected: s.accent == id, label: l.accent(id),
                  child: GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); ctl.setAccent(id); },
                    child: Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          border: Border.all(color: c.sf, width: 3),
                          boxShadow: [BoxShadow(color: s.accent == id ? c.ink : c.ln, spreadRadius: s.accent == id ? 3 : 1.5)],
                        ),
                        child: s.accent == id ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                      ),
                      const SizedBox(height: 6),
                      ExcludeSemantics(child: Text(l.accent(id), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.accent == id ? c.ink : c.ink2))),
                    ]),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
            Cap(l.preview),
            const SizedBox(height: 8),
            const _Preview(),
          ]),
        ),
      ]),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: c.bg, border: Border.all(color: c.ln), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(gradient: c.heroGradient),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HmBadge(context.l.kingdom_plant, glass: true),
              const SizedBox(height: 6),
              Text('Arnica montana', style: latinStyle(size: 24, color: Colors.white)),
              Text("Leopard's Bane", style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: .96))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const HmChip('30C', small: true, selected: true),
              const SizedBox(width: 8),
              const HmChip('200C', small: true),
              const Spacer(),
              Container(
                height: 36, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center,
                decoration: BoxDecoration(color: c.p, borderRadius: BorderRadius.circular(12)),
                child: Text(context.l.doseGuide, style: TextStyle(color: c.onp, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Sun-and-clouds / moon-and-stars switch from the design (`.dn`).
class DayNightSwitch extends StatelessWidget {
  const DayNightSwitch({super.key, required this.night, required this.onChanged});
  final bool night;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dur = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 350);
    return Semantics(
      toggled: night, button: true, label: night ? context.l.nightMode : context.l.dayMode,
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onChanged(!night); },
        child: AnimatedContainer(
          duration: dur,
          width: 116, height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: LinearGradient(colors: night ? const [Color(0xFF0B1B36), Color(0xFF283A66)] : const [Color(0xFF6CC4F0), Color(0xFFB7E3F8)]),
          ),
          child: Stack(children: [
            AnimatedOpacity(duration: dur, opacity: night ? 0 : .95, child: Stack(children: [
              Positioned(right: 14, top: 26, child: _pill(34, 14)),
              Positioned(right: 30, top: 18, child: _pill(22, 12)),
            ])),
            AnimatedOpacity(duration: dur, opacity: night ? .9 : 0, child: Stack(children: [
              for (final (x, y, d) in const [(18.0, 14.0, 3.0), (34.0, 30.0, 2.0), (12.0, 36.0, 2.0), (44.0, 12.0, 2.0)])
                Positioned(left: x, top: y, child: Container(width: d, height: d, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
            ])),
            AnimatedPositioned(
              duration: dur, curve: const Cubic(.4, 1.4, .6, 1),
              left: night ? 66 : 6, top: 6,
              child: AnimatedContainer(
                duration: dur,
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(center: const Alignment(-.3, -.3), colors: night ? const [Color(0xFFF4F6FA), Color(0xFFC9D2E2)] : const [Color(0xFFFFE680), Color(0xFFFFC21A)]),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: night
                    ? Stack(children: [Positioned(left: 10, top: 12, child: _crater(10)), Positioned(left: 24, top: 26, child: _crater(7))])
                    : null,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _pill(double w, double h) => Container(width: w, height: h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)));
  static Widget _crater(double d) => Container(width: d, height: d, decoration: const BoxDecoration(color: Color(0x597887A5), shape: BoxShape.circle));
}

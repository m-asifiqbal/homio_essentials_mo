/// Onboarding pages: welcome, a single-choice page, the disclaimer.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), children: [
      HeroBox(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HmLogo(size: 64),
          const SizedBox(height: 18),
          Text(AppInfo.localizedName(context.bn), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: context.bn ? 0 : .5, color: Colors.white.withValues(alpha: .96))),
          const SizedBox(height: 4),
          Text(l.welcomeTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, color: Colors.white)),
          const SizedBox(height: 10),
          Text(l.welcomeBody, style: TextStyle(fontSize: 15, height: 1.55, color: Colors.white.withValues(alpha: .96))),
        ]),
      ),
      const SizedBox(height: 20),
      for (final (icon, text) in [(Icons.menu_book_outlined, l.welcomePoint1), (Icons.child_care_outlined, l.welcomePoint2), (Icons.mic_none_rounded, l.welcomePoint3)])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HmCard(
            child: Row(children: [
              IconTile(icon, (c.sf2, c.pd)),
              const SizedBox(width: 14),
              Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
    ]);
  }
}

class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key, required this.title, this.note, required this.options, required this.value, required this.onPick, this.icons});
  final String title;
  final String? note;
  final List<(String, String, String, String?)> options; // value, title, subtitle, glyph
  final List<IconData>? icons;
  final String value;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 32, 20, 20), children: [
      Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      if (note != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(note!, style: TextStyle(color: c.ink2))),
      const SizedBox(height: 24),
      for (final (i, (v, t, sub, glyph)) in options.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Semantics(
            selected: v == value,
            inMutuallyExclusiveGroup: true,
            child: HmCard(
              onTap: () => onPick(v),
              border: v == value ? c.p : null,
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(
                  width: 52, height: 52, alignment: Alignment.center,
                  decoration: BoxDecoration(color: v == value ? c.p : c.sf2, borderRadius: BorderRadius.circular(16)),
                  child: glyph != null
                      ? Text(glyph, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: v == value ? c.onp : c.pd))
                      : Icon(icons?[i] ?? Icons.circle_outlined, color: v == value ? c.onp : c.pd),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(sub, style: TextStyle(color: c.ink2, fontSize: 14)),
                  ]),
                ),
                Icon(v == value ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: v == value ? c.p : c.ink3),
              ]),
            ),
          ),
        ),
    ]);
  }
}

class DisclaimerPage extends ConsumerWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final a = ref.watch(archiveProvider).value;
    final text = a?.configText('disclaimer', context.bn) ?? context.l.disclaimerFallback;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 32, 20, 20), children: [
      IconTile(Icons.health_and_safety_outlined, (c.am, c.amInk), size: 64),
      const SizedBox(height: 20),
      Text(context.l.beforeYouStart, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      Text(text, style: const TextStyle(fontSize: 16, height: 1.65)),
      const SizedBox(height: 20),
      Callout(CalloutKind.note, child: Text(context.l.sourceCurated(AppInfo.localizedName(context.bn)))),
    ]);
  }
}

/// EN / বাং pill (design `.lp`) — switches the app language in place.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class LangPill extends ConsumerWidget {
  const LangPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final locale = ref.watch(settingsProvider.select((s) => s.locale));
    Widget opt(String code, String label, String semantic) => Semantics(
          button: true, selected: locale == code, label: semantic,
          child: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); ref.read(settingsProvider.notifier).setLocale(code); },
            child: AnimatedContainer(
              duration: context.motion(HmMotion.fast),
              curve: HmMotion.curve,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: locale == code ? c.p : Colors.transparent, borderRadius: BorderRadius.circular(99)),
              child: ExcludeSemantics(child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: locale == code ? c.onp : c.ink2))),
            ),
          ),
        );
    return Semantics(
      label: context.l.language,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(99), border: Border.all(color: c.ln)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [opt('en', 'EN', 'English'), opt('bn', 'বাং', 'বাংলা')]),
      ),
    );
  }
}

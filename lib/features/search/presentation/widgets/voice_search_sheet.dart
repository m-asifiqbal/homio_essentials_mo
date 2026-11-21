/// ============================================================
/// VOICE SEARCH SHEET — pulsing mic, live words, Bangla or English
/// ============================================================
///
/// Listens in the app language. Closes itself with the final words (which
/// become the query); explains plainly when the mic is blocked or the
/// phone has no speech recognizer.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/platform/voice_input.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

Future<void> openVoiceSearch(BuildContext context, WidgetRef ref) async {
  HapticFeedback.mediumImpact();
  final ctl = ref.read(searchControllerProvider.notifier);
  ctl.startVoice(ref.read(settingsProvider).locale);
  await showModalBottomSheet<void>(context: context, builder: (_) => const _VoiceSheet());
  if (ref.read(searchControllerProvider).voice == VoiceStatus.listening) await ctl.stopVoice();
  ctl.resetVoice();
}

class _VoiceSheet extends ConsumerStatefulWidget {
  const _VoiceSheet();
  @override
  ConsumerState<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<_VoiceSheet> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    final s = ref.watch(searchControllerProvider);
    ref.listen(searchControllerProvider.select((s) => s.voice), (_, v) {
      if (v == VoiceStatus.done && Navigator.canPop(context)) Navigator.pop(context);
    });
    final listening = s.voice == VoiceStatus.listening || s.voice == VoiceStatus.starting;
    final problem = switch (s.voice) {
      VoiceStatus.denied => l.voiceDenied,
      VoiceStatus.unavailable => l.voiceUnavailable,
      VoiceStatus.error => l.voiceNothingHeard,
      _ => null,
    };
    final still = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(problem == null ? (listening ? l.voiceListening : l.voiceSearch) : l.voiceSearch, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(context.bn ? l.voiceInBangla : l.voiceInEnglish, style: TextStyle(color: c.ink2, fontSize: 13)),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            label: listening ? l.voiceTapToStop : l.voiceTryAgain,
            child: GestureDetector(
              onTap: () {
                final ctl = ref.read(searchControllerProvider.notifier);
                listening ? ctl.stopVoice() : ctl.startVoice(ref.read(settingsProvider).locale);
              },
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final t = listening && !still ? _pulse.value : 0.0;
                  return Container(
                    width: 132, height: 132, alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.p.withValues(alpha: .10 + .10 * t)),
                    child: Container(
                      width: 96 + 12 * t, height: 96 + 12 * t,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: problem != null ? c.sf3 : c.p,
                          boxShadow: [if (listening) BoxShadow(color: c.p.withValues(alpha: .35), blurRadius: 24 * t + 8)]),
                      child: Icon(problem != null ? Icons.mic_off_rounded : Icons.mic_rounded, size: 44, color: problem != null ? c.ink2 : c.onp),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Text(
              problem ?? (s.voiceWords.isEmpty ? l.voiceSpeakNow : '“${s.voiceWords}”'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: s.voiceWords.isEmpty || problem != null ? 15 : 20, fontWeight: s.voiceWords.isEmpty ? FontWeight.w500 : FontWeight.w700, color: problem != null ? c.dgInk : c.ink, height: 1.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(listening ? l.voiceTapToStop : l.voiceTryAgain, style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ]),
      ),
    );
  }
}

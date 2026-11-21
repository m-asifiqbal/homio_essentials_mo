/// ============================================================
/// ONBOARDING — welcome → language → detail level → disclaimer (first launch)
/// ============================================================
///
/// The archive starts downloading on the first page, so Home is usually
/// ready by the time the user taps "I understand".
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/features/onboarding/presentation/widgets/onboarding_pages.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _i = 0;

  @override
  void initState() {
    super.initState();
    ref.read(archiveProvider); // warm the archive while the user reads
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _i = i);
    _page.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final pages = [
      const WelcomePage(),
      ChoicePage(
        title: l.chooseLanguage, note: l.languageNote,
        options: const [('en', 'English', 'Read the archive in English', 'Aa'), ('bn', 'বাংলা', 'আর্কাইভ বাংলায় পড়ুন', 'অ')],
        value: s.locale, onPick: ctl.setLocale,
      ),
      ChoicePage(
        title: l.chooseRole(AppInfo.localizedName(context.bn)),
        options: [
          (Role.general.name, l.roleGeneral, l.roleGeneralDesc, null),
          (Role.student.name, l.roleStudent, l.roleStudentDesc, null),
          (Role.practitioner.name, l.rolePractitioner, l.rolePractitionerDesc, null),
        ],
        icons: const [Icons.person_outline_rounded, Icons.school_outlined, Icons.medical_services_outlined],
        value: s.role.name, onPick: (v) => ctl.setRole(Role.values.byName(v)),
      ),
      const DisclaimerPage(),
    ];
    final last = _i == pages.length - 1;
    return PopScope(
      canPop: _i == 0,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _go(_i - 1); },
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                if (_i > 0) IconButton.outlined(onPressed: () => _go(_i - 1), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back) else const SizedBox(height: 48),
                const Spacer(),
                Semantics(
                  label: '${_i + 1} / ${pages.length}',
                  child: Row(children: [
                    for (var k = 0; k < pages.length; k++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(start: 6), width: k == _i ? 24 : 8, height: 8,
                        decoration: BoxDecoration(color: k == _i ? c.p : c.sf3, borderRadius: BorderRadius.circular(99)),
                      ),
                  ]),
                ),
              ]),
            ),
            Expanded(child: PageView(controller: _page, physics: const NeverScrollableScrollPhysics(), children: pages)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                onPressed: () {
                  if (!last) return _go(_i + 1);
                  ctl.completeOnboarding();
                  context.go(AppRoutes.home);
                },
                child: Text(_i == 0 ? l.getStarted : last ? l.iUnderstand : l.next),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

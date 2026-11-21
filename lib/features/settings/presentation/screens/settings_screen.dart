/// ============================================================
/// SETTINGS SCREEN — appearance, reading, contribute, contact (live), data & about
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/ad_service.dart';
import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/requests/presentation/widgets/report_sheet.dart';
import 'package:homio_essentials/features/settings/presentation/providers/settings_screen_providers.dart';
import 'package:homio_essentials/features/settings/presentation/widgets/appearance_card.dart';
import 'package:homio_essentials/features/settings/presentation/widgets/settings_list.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final a = ref.watch(archiveProvider).value;
    final sync = ref.watch(syncStateProvider);
    final size = ref.watch(cacheSizeProvider).value;
    final adPrivacy = ref.watch(adPrivacyRequiredProvider).value ?? false;
    final sizeText = size == null ? '…' : sizeL(context, size);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          Gutter(top: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.settingsTitle, style: Theme.of(context).textTheme.headlineMedium),
            Text(l.settingsSub, style: TextStyle(color: c.ink2, fontSize: 13)),
          ])),
          SettingsGroupLabel(l.appearance),
          const Gutter(child: AppearanceCard()),
          SettingsGroupLabel(l.reading),
          Gutter(
            child: HmCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(l.textSize, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(s.textScale < .97 ? l.textSmall : s.textScale > 1.12 ? l.textLarge : l.textMedium, style: TextStyle(fontSize: 13, color: c.ink2)),
                ]),
                Row(children: [
                  const ExcludeSemantics(child: Text('A', style: TextStyle(fontSize: 13))),
                  Expanded(child: Slider(value: s.textScale, min: .9, max: 1.3, divisions: 4, label: l.textSize, onChanged: ctl.setTextScale)),
                  const ExcludeSemantics(child: Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 8),
                Text(l.language, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Segmented<String>(options: const [('en', 'English'), ('bn', 'বাংলা')], value: s.locale, onChanged: ctl.setLocale),
                const SizedBox(height: 14),
                Text(l.detailLevel, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Segmented<Role>(
                  options: [(Role.general, l.roleGeneral), (Role.student, l.roleStudent), (Role.practitioner, l.rolePractitioner)],
                  value: s.role, onChanged: ctl.setRole,
                ),
                const SizedBox(height: 8),
                Text(l.modeNote(s.role.name), style: TextStyle(fontSize: 12.5, color: c.ink2)),
              ]),
            ),
          ),
          SettingsGroupLabel(l.contribute),
          Gutter(child: SettingsList(items: [
            SettingsItem(Icons.add_rounded, (c.pe, c.peInk), l.requestMedicine, l.requestMedicineSub, () => context.push(AppRoutes.request)),
            SettingsItem(Icons.assignment_outlined, (c.am, c.amInk), l.myRequests, l.myRequestsSub, () => context.push(AppRoutes.myRequests)),
            SettingsItem(Icons.flag_outlined, (c.dg, c.dgInk), l.reportError, l.reportErrorSub, () => showReportSheet(context, ref)),
          ])),
          SettingsGroupLabel(l.contactUs),
          Gutter(
            child: (a == null || a.contacts.isEmpty)
                ? HmCard(child: Text(l.contactEmpty, style: TextStyle(color: c.ink2)))
                : SettingsList(items: [
                    for (final ch in a.contacts)
                      SettingsItem(_contactIcon(ch.type), (c.ptBg, c.ptInk), ch.label.of(context.bn) ?? ch.type, ch.value, () => openTarget(ch.type, ch.value)),
                    if (a.config['office_hours'] is Map)
                      SettingsItem(Icons.schedule_rounded, (c.sf2, c.pd), '${(a.config['office_hours'] as Map)['opens']}–${(a.config['office_hours'] as Map)['closes']}',
                          ((a.config['office_hours'] as Map)['days'] as List? ?? const []).join(', '), null),
                  ]),
          ),
          SettingsGroupLabel(l.dataAbout),
          Gutter(child: SettingsList(items: [
            SettingsItem(Icons.download_done_rounded, (c.ptBg, c.ptInk), l.offlineData,
                sync == SyncState.syncing ? l.updating : sync == SyncState.offline ? l.offlineSaved(sizeText) : l.upToDate(sizeText), () => context.push(AppRoutes.offline)),
            SettingsItem(Icons.info_outline_rounded, (c.miBg, c.miInk), l.medicalDisclaimer, null, () => context.push(AppRoutes.disclaimer)),
            SettingsItem(Icons.menu_book_outlined, (c.anBg, c.anInk), l.sourcesCredits, null, () => context.push(AppRoutes.sources)),
            if (adPrivacy) SettingsItem(Icons.privacy_tip_outlined, (c.noBg, c.noInk), l.adPrivacy, l.adPrivacySub, () => ref.read(adServiceProvider).showPrivacyOptions()),
            SettingsItem(null, (c.sf2, c.pd), AppInfo.localizedName(context.bn),
                l.versionLine(AppInfo.version, a == null ? '—' : '${a.syncedAt.year}.${a.syncedAt.month.toString().padLeft(2, '0')}'), null, logo: true),
          ])),
        ]),
      ),
    );
  }

  static IconData _contactIcon(String t) => switch (t) {
        'phone' => Icons.call_outlined,
        'whatsapp' => Icons.chat_outlined,
        'email' => Icons.mail_outline_rounded,
        'facebook' || 'messenger' => Icons.facebook_rounded,
        'youtube' => Icons.smart_display_outlined,
        'address' => Icons.place_outlined,
        _ => Icons.public_rounded,
      };
}

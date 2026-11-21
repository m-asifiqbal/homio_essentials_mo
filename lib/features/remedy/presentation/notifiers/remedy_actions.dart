/// ============================================================
/// REMEDY ACTIONS — save (with Undo), share, record a view
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';

abstract final class RemedyActions {
  static void toggleSave(BuildContext context, WidgetRef ref, String slug) {
    final l = context.l;
    final ctl = ref.read(savedProvider.notifier);
    final before = ref.read(savedProvider);
    final nowSaved = ctl.toggle(slug);
    HapticFeedback.lightImpact();
    showHmSnack(context, nowSaved ? l.savedSnack : l.removedSnack, action: nowSaved ? null : l.undo, onAction: () => ctl.restore(before));
  }

  static void recordView(WidgetRef ref, String slug) => ref.read(historyProvider.notifier).push(slug);

  static Future<void> share(BuildContext context, Remedy r) {
    final bangla = context.bn;
    final lines = [
      r.latin,
      [r.common(bangla), r.abbr].whereType<String>().join(' · '),
      if (r.summary(bangla) != null) '\n${r.summary(bangla)}',
      '\n— ${AppInfo.localizedName(bangla)}',
    ].where((s) => s.trim().isNotEmpty).join('\n');
    return SharePlus.instance.share(ShareParams(text: lines, subject: r.latin));
  }
}

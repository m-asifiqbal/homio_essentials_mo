/// Bottom sheet that files a content report for an editor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/features/requests/presentation/providers/requests_providers.dart';

Future<void> showReportSheet(BuildContext context, WidgetRef ref, {String entityType = 'other', String? entityId}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReportSheet(entityType: entityType, entityId: entityId),
    );

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.entityType, this.entityId});
  final String entityType;
  final String? entityId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_ctl.text.trim().length < 3) return;
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(submitControllerProvider.notifier).sendReport(message: _ctl.text.trim(), entityType: widget.entityType, entityId: widget.entityId);
    if (!mounted) return;
    if (ok) Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(ok ? l.reportSent : l.sendFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final sending = ref.watch(submitControllerProvider) == SubmitStatus.sending;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.reportTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(controller: _ctl, autofocus: true, minLines: 3, maxLines: 6, maxLength: 2000, decoration: InputDecoration(hintText: l.reportHint)),
        const SizedBox(height: 8),
        FilledButton(onPressed: sending ? null : _send, child: Text(l.send)),
      ]),
    );
  }
}

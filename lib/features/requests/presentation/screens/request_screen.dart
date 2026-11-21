/// ============================================================
/// REQUEST SCREEN — "Request a new medicine" (remedy or brand)
/// ============================================================
///
/// Goes to the admin app's review queue. Nothing is published until an
/// editor approves it.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/requests/presentation/providers/requests_providers.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key, this.prefill, this.kind});
  final String? prefill, kind;

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _form = GlobalKey<FormState>();
  late String _kind = widget.kind == 'product' ? 'product' : 'remedy';
  late final _name = TextEditingController(text: widget.prefill ?? '');
  final _common = TextEditingController();
  final _brand = TextEditingController();
  final _potency = TextEditingController();
  final _notes = TextEditingController();
  late Role _role = ref.read(settingsProvider).role;

  @override
  void dispose() {
    for (final c in [_name, _common, _brand, _potency, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l;
    final ok = await ref.read(submitControllerProvider.notifier).sendRequest(kind: _kind, role: _role, payload: {
      'latin_name': _name.text.trim(),
      if (_common.text.trim().isNotEmpty) (context.bn ? 'bangla_name' : 'common_name'): _common.text.trim(),
      if (_brand.text.trim().isNotEmpty) 'brand': _brand.text.trim(),
      if (_potency.text.trim().isNotEmpty) 'potency': _potency.text.trim(),
      if (_notes.text.trim().isNotEmpty) 'description': _notes.text.trim(),
      'app_locale': context.bn ? 'bn' : 'en',
    });
    if (!mounted) return;
    showHmSnack(context, ok ? l.requestSent : l.sendFailed);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final sending = ref.watch(submitControllerProvider) == SubmitStatus.sending;
    String? req(String? v) => (v == null || v.trim().length < 2) ? l.fieldRequired : null;
    Widget field(String label, TextEditingController ctl, {String? hint, String? Function(String?)? validator, int lines = 1}) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            TextFormField(
              controller: ctl, validator: validator, minLines: lines, maxLines: lines == 1 ? 1 : 5, maxLength: lines == 1 ? 120 : 1000,
              textInputAction: lines == 1 ? TextInputAction.next : TextInputAction.newline,
              decoration: InputDecoration(hintText: hint, counterText: ''),
            ),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.requestTitle)),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Text(l.requestIntro, style: TextStyle(color: c.ink2, height: 1.5)),
          const SizedBox(height: 16),
          Segmented<String>(options: [('remedy', l.kindRemedyLabel), ('product', l.kindProductLabel)], value: _kind, onChanged: (v) => setState(() => _kind = v)),
          const SizedBox(height: 18),
          field(l.fieldLatin, _name, hint: l.fieldLatinHint, validator: req),
          field(l.fieldCommon, _common),
          if (_kind == 'product') field(l.fieldBrand, _brand, hint: l.fieldBrandHint, validator: req),
          field(l.fieldPotency, _potency),
          field(l.fieldNotes, _notes, lines: 3),
          Text(l.iAmA, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Segmented<Role>(options: [(Role.general, l.roleGeneral), (Role.student, l.roleStudent), (Role.practitioner, l.rolePractitioner)], value: _role, onChanged: (v) => setState(() => _role = v)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: sending ? null : _send,
            child: sending ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: c.onp)) : Text(l.sendRequest),
          ),
        ]),
      ),
    );
  }
}

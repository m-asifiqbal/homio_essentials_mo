/// Back · search field (clear) · voice button.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/voice_search_sheet.dart';

class SearchTopBar extends ConsumerWidget {
  const SearchTopBar({super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final ctl = ref.read(searchControllerProvider.notifier);
    final empty = ref.watch(searchControllerProvider.select((s) => s.input.isEmpty));
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: c.p, width: 2));
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 16, 6),
      child: Row(children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: ctl.setInput,
            onSubmitted: (v) { ctl.searchNow(v); ctl.remember(v); },
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: l.searchFieldHint,
              prefixIcon: Icon(Icons.search_rounded, color: c.p),
              suffixIcon: empty
                  ? null
                  : IconButton(icon: const Icon(Icons.close_rounded), tooltip: l.clear, onPressed: () { ctl.clear(); focusNode.requestFocus(); }),
              enabledBorder: border,
              focusedBorder: border,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: c.sf2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () { focusNode.unfocus(); openVoiceSearch(context, ref); },
            child: Tooltip(message: l.voiceSearch, child: SizedBox(width: 52, height: 52, child: Icon(Icons.mic_rounded, color: c.pd))),
          ),
        ),
      ]),
    );
  }
}

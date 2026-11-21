/// Back · one rounded search field with the mic inside it (clear appears once you type).
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/voice_search_sheet.dart';

class SearchTopBar extends ConsumerStatefulWidget {
  const SearchTopBar({super.key, required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  ConsumerState<SearchTopBar> createState() => _SearchTopBarState();
}

class _SearchTopBarState extends ConsumerState<SearchTopBar> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final ctl = ref.read(searchControllerProvider.notifier);
    final empty = ref.watch(searchControllerProvider.select((s) => s.input.isEmpty));
    final focused = widget.focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 8, 16, 8),
      child: Row(children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back),
        Expanded(
          child: AnimatedContainer(
            duration: context.motion(HmMotion.fast),
            curve: HmMotion.curve,
            height: 50,
            decoration: BoxDecoration(
              color: c.sf,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: focused ? c.p : c.ln, width: focused ? 1.75 : 1),
              boxShadow: focused ? [BoxShadow(color: c.ring, blurRadius: 10, spreadRadius: 1)] : c.cardShadow,
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded, color: focused ? c.p : c.ink3, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: ctl.setInput,
                  onSubmitted: (v) { ctl.searchNow(v); ctl.remember(v); },
                  textInputAction: TextInputAction.search,
                  cursorColor: c.p,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isCollapsed: true, filled: false,
                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: l.searchFieldHint,
                    hintStyle: TextStyle(color: c.ink3, fontSize: 14.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: context.motion(HmMotion.fast),
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: child)),
                child: empty
                    ? const SizedBox(key: ValueKey('none'), width: 4)
                    : IconButton(
                        key: const ValueKey('clear'),
                        icon: Icon(Icons.cancel_rounded, color: c.ink3, size: 20),
                        tooltip: l.clear,
                        visualDensity: VisualDensity.compact,
                        onPressed: () { HapticFeedback.selectionClick(); ctl.clear(); widget.focusNode.requestFocus(); },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: HmPressable(
                  onTap: () { widget.focusNode.unfocus(); openVoiceSearch(context, ref); },
                  child: Tooltip(
                    message: l.voiceSearch,
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.mic_rounded, color: c.pd, size: 21)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

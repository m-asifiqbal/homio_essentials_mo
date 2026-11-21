/// ============================================================
/// SEARCH SCREEN — instant offline search, filters, voice, book text
/// ============================================================
///
/// Before typing: recent searches, recently viewed, popular remedies,
/// symptoms. While typing: grouped results with category counts, matched
/// aliases, "did you mean", plus full-text hits inside the books (online).
/// `?q=` searches immediately, `?voice=1` opens straight into listening.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_category_bar.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_idle_view.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_results_view.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_top_bar.dart';
import 'package:homio_essentials/features/search/presentation/widgets/voice_search_sheet.dart';
import 'package:homio_essentials/shared/widgets/archive_gate.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery, this.startWithVoice = false});
  final String? initialQuery;
  final bool startWithVoice;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _field = TextEditingController(text: widget.initialQuery ?? '');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctl = ref.read(searchControllerProvider.notifier);
      if (widget.initialQuery?.isNotEmpty ?? false) ctl.searchNow(widget.initialQuery!);
      if (widget.startWithVoice) {
        openVoiceSearch(context, ref);
      } else if (widget.initialQuery == null) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Keeps the text field in step when a chip / voice result sets the query.
  void _syncField(String input) {
    if (_field.text == input) return;
    _field.value = TextEditingValue(text: input, selection: TextSelection.collapsed(offset: input.length));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchControllerProvider.select((s) => s.input), (_, input) => _syncField(input));
    final hasQuery = ref.watch(searchControllerProvider.select((s) => s.hasQuery));
    return Scaffold(
      body: SafeArea(
        child: ArchiveGate(
          builder: (context, archive) => Column(children: [
            SearchTopBar(controller: _field, focusNode: _focus),
            const SearchCategoryBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: hasQuery ? SearchResultsView(key: const ValueKey('results'), archive: archive) : SearchIdleView(key: const ValueKey('idle'), archive: archive),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

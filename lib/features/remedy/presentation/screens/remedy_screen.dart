/// ============================================================
/// REMEDY SCREEN — hero + one page of collapsible sections with a sticky index
/// ============================================================
///
/// Redesigned after MedEx's brand pages (header block, then Indications ·
/// Dosage & Administration · Contraindications / Precautions · Brands …), with the
/// things MedEx lacks: a PINNED jump-to-section index that follows the scroll
/// (scroll-spy), expand / collapse all, sources + "data updated" + report-an-error,
/// and a back-to-top pill.
///
/// One CustomScrollView: pinned app bar → hero → pinned index → section cards.
/// The cards are a plain Column inside one sliver, so every section's GlobalKey is
/// always mounted (needed for scroll-spy) and the inline ad is never re-requested.
/// `?tab=` deep links open and scroll to a section (`study` → Materia Medica).
/// ============================================================
library;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/promotions/presentation/widgets/promo_slider.dart';
import 'package:homio_essentials/features/remedy/presentation/notifiers/remedy_actions.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_index_bar.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/brands_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/dosage_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/keynotes_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/materia_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/overview_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/relations_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/safety_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/sources_section.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/sections/uses_section.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';

/// Old `?tab=` values → section ids.
const _tabToSection = {'overview': 'overview', 'uses': 'uses', 'dosage': 'dosage', 'brands': 'brands', 'study': 'materia'};

class RemedyScreen extends ConsumerStatefulWidget {
  const RemedyScreen({super.key, required this.slug, this.tab});
  final String slug;
  final String? tab;

  @override
  ConsumerState<RemedyScreen> createState() => _RemedyScreenState();
}

class _RemedyScreenState extends ConsumerState<RemedyScreen> {
  final _scroll = ScrollController();
  final _keys = <String, GlobalKey>{};
  final _open = <String>{};
  final _active = ValueNotifier<String>('overview');
  final _allOpen = ValueNotifier<bool>(false);
  final _titleShown = ValueNotifier<bool>(false);

  List<String> _ids = const [];
  bool _seeded = false;

  /// Set when the user taps an index chip: the spy stays quiet while the jump animates and while the
  /// page rests near the landing offset; the first real scroll away from it hands control back.
  String? _manual;
  double _manualOffset = 0;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => RemedyActions.recordView(ref, widget.slug));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    _allOpen.dispose();
    _titleShown.dispose();
    super.dispose();
  }

  GlobalKey _key(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// Height of everything pinned above the content: status bar + app bar + index.
  double get _pinned => MediaQuery.paddingOf(context).top + kToolbarHeight + RemedyIndexBar.height;

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final shown = _scroll.offset > 150;
    if (_titleShown.value != shown) _titleShown.value = shown;
    if (_ids.isEmpty) return;
    if (_manual != null) {
      if (_animating || (_scroll.offset - _manualOffset).abs() < 12) return;
      _manual = null; // scrolled away from the landing spot (touch, wheel or keyboard): follow the page again
    }
    final line = _pinned + 28;
    var current = _ids.first;
    for (final id in _ids) {
      final box = _keys[id]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= line) {
        current = id;
      } else {
        break;
      }
    }
    // At the very bottom the last section is the one being read, however short it is.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 4) current = _ids.last;
    if (_active.value != current) _active.value = current;
  }

  void _syncAllOpen() => _allOpen.value = _ids.isNotEmpty && _ids.every(_open.contains);

  void _toggle(String id) {
    setState(() => _open.contains(id) ? _open.remove(id) : _open.add(id));
    _syncAllOpen();
  }

  void _toggleAll() {
    setState(() => _allOpen.value ? _open.clear() : _open.addAll(_ids));
    _syncAllOpen();
  }

  /// Opens a section and scrolls it just under the pinned bars.
  void _go(String id) {
    if (!_ids.contains(id)) return;
    _manual = id;
    _active.value = id;
    setState(() => _open.add(id));
    _syncAllOpen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _keys[id]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !_scroll.hasClients) return;
      // getOffsetToReveal already accounts for the pinned app bar + index overlapping the viewport's
      // leading edge, so the card lands right under them; only a small breathing gap is added.
      final reveal = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
      final target = (reveal - 10).clamp(0.0, _scroll.position.maxScrollExtent);
      _manualOffset = target;
      _animating = true;
      _scroll.animateTo(target, duration: context.motion(const Duration(milliseconds: 380)), curve: Curves.easeOutCubic).whenComplete(() => _animating = false);
    });
  }

  List<RemedySectionSpec> _specs(RemedyDetail d) {
    final l = context.l;
    final c = context.hm;
    final bangla = context.bn;
    final r = d.remedy;
    final pots = d.potencies;
    return [
      RemedySectionSpec(
        id: 'overview', title: l.secOverview, icon: Icons.info_outline_rounded, tone: (c.sf2, c.pd),
        summary: [r.common(bangla), l.kingdom(r.kingdom)].whereType<String>().join(' · '),
        builder: (_) => OverviewSection(d: d, goSection: _go),
      ),
      if (d.uses.isNotEmpty)
        RemedySectionSpec(
          id: 'uses', title: l.secUses, icon: Icons.fact_check_outlined, tone: (c.dg, c.dgInk), count: d.uses.length,
          summary: d.uses.take(3).map((u) => d.conditionsById[u.conditionId]?.name(bangla) ?? u.title(bangla)).whereType<String>().join(' · '),
          builder: (_) => UsesSection(d: d, goSection: _go),
        ),
      RemedySectionSpec(
        id: 'dosage', title: l.secDosage, icon: Icons.medication_outlined, tone: (c.ptBg, c.ptInk),
        summary: pots.isEmpty ? l.doseGuideSub : pots.join(' · '),
        builder: (_) => DosageSection(d: d),
      ),
      if (r.keynotes.isNotEmpty)
        RemedySectionSpec(
          id: 'keynotes', title: l.keynotes, icon: Icons.key_rounded, tone: (c.bcBg, c.bcInk), count: r.keynotes.length,
          summary: r.keynotes.first,
          builder: (_) => KeynotesSection(notes: r.keynotes),
        ),
      RemedySectionSpec(
        id: 'safety', title: l.secSafety, icon: Icons.health_and_safety_outlined, tone: (c.am, c.amInk), count: d.safety.isEmpty ? null : d.safety.length,
        summary: l.secSafetySummary,
        builder: (_) => SafetySection(d: d),
      ),
      if (d.related.isNotEmpty)
        RemedySectionSpec(
          id: 'relations', title: l.secRelations, icon: Icons.hub_outlined, tone: (c.noBg, c.noInk), count: d.related.length,
          summary: d.related.take(3).map((x) => x.remedy.latin).join(' · '),
          builder: (_) => RelationsSection(related: d.related),
        ),
      RemedySectionSpec(
        id: 'brands', title: l.secBrands, icon: Icons.sell_outlined, tone: (c.miBg, c.miInk), count: d.products.isEmpty ? null : d.products.length,
        summary: d.products.isEmpty ? l.brandsEmptyTitle : null,
        builder: (_) => BrandsSection(d: d),
      ),
      RemedySectionSpec(
        id: 'materia', title: l.materiaMedica, icon: Icons.menu_book_outlined, tone: (c.anBg, c.anInk),
        summary: l.secMateriaSummary,
        builder: (_) => MateriaSection(d: d),
      ),
      RemedySectionSpec(
        id: 'sources', title: l.secSources, icon: Icons.verified_outlined, tone: (c.ok, c.okInk),
        summary: l.secSourcesSummary,
        builder: (_) => SourcesSection(r: r),
      ),
    ];
  }

  /// First build with data: decide which sections start open and honour a `?tab=` deep link.
  void _seed(List<RemedySectionSpec> specs) {
    _ids = [for (final s in specs) s.id];
    if (_seeded) return;
    _seeded = true;
    _open.addAll(['overview', 'uses', 'dosage'].where(_ids.contains));
    final target = _tabToSection[widget.tab];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAllOpen();
      if (target != null && target != 'overview') _go(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    final saved = ref.watch(savedProvider.select((s) => s.contains(widget.slug)));
    final detail = ref.watch(remedyDetailProvider(widget.slug));
    return Scaffold(
      body: switch (detail) {
        AsyncValue(:final value?) => _page(context, value, saved),
        AsyncValue(hasValue: true) => SafeArea(
            child: Column(children: [
              Align(alignment: AlignmentDirectional.centerStart, child: Padding(padding: const EdgeInsets.all(12), child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back))),
              Expanded(child: EmptyState(icon: Icons.search_off_rounded, title: l.notFound)),
            ]),
          ),
        AsyncError() => Center(child: EmptyState(icon: Icons.cloud_off_rounded, title: l.loadFailedTitle, body: l.loadFailedBody)),
        _ => Center(child: CircularProgressIndicator(color: c.p)),
      },
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(color: c.sf, border: Border(top: BorderSide(color: c.ln))),
          child: Row(children: [
            SizedBox(
              width: 50, height: 50,
              child: IconButton.outlined(
                onPressed: () => RemedyActions.toggleSave(context, ref, widget.slug), tooltip: l.save,
                style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: c.ln)),
                icon: AnimatedSwitcher(
                  duration: context.motion(HmMotion.fast),
                  transitionBuilder: (child, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: child),
                  child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, key: ValueKey(saved), color: c.p),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.icon(onPressed: () => _go('dosage'), icon: const Icon(Icons.medication_outlined), label: Text(l.doseGuide))),
          ]),
        ),
      ),
    );
  }

  Widget _page(BuildContext context, RemedyDetail? d, bool saved) {
    final l = context.l;
    final c = context.hm;
    if (d == null) return const SizedBox.shrink();
    final r = d.remedy;
    final specs = _specs(d);
    _seed(specs);
    final prices = d.products.map((p) => p.price).whereType<double>();
    final priceFrom = prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
    Widget card(RemedySectionSpec s) => KeyedSubtree(
          key: _key(s.id),
          child: RemedySectionCard(spec: s, open: _open.contains(s.id), onToggle: () {
            _manual = null;
            _toggle(s.id);
          }),
        );
    return Stack(children: [
      NotificationListener<ScrollStartNotification>(
        // The user took over: let the spy follow the page again.
        onNotification: (n) {
          if (n.dragDetails != null) _manual = null;
          return false;
        },
        // No stretch / glow overscroll on this page: Android 12+'s stretch moves the pinned app bar and index
        // together with the content when you reach the top, which looks like a glitch.
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: c.hero1,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: ValueListenableBuilder<bool>(
                valueListenable: _titleShown,
                builder: (context, shown, _) => AnimatedOpacity(
                  duration: context.motion(HmMotion.fast),
                  opacity: shown ? 1 : 0,
                  child: Text(r.latin, maxLines: 1, overflow: TextOverflow.ellipsis, style: latinStyle(size: 19, color: Colors.white)),
                ),
              ),
              leading: Padding(padding: const EdgeInsets.all(6), child: GlassButton(icon: Icons.arrow_back_rounded, tooltip: l.back, onTap: () => context.pop())),
              actions: [
                GlassButton(icon: Icons.ios_share_rounded, tooltip: l.share, onTap: () => RemedyActions.share(context, r)),
                const SizedBox(width: 8),
                GlassButton(icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, tooltip: l.save, onTap: () => RemedyActions.toggleSave(context, ref, widget.slug)),
                const SizedBox(width: 12),
              ],
            ),
            SliverToBoxAdapter(child: RemedyHero(r: r, brandCount: d.products.length, priceFrom: priceFrom)),
            SliverPersistentHeader(
              pinned: true,
              delegate: RemedyIndexBar(
                heroColor: c.hero2, colors: c, specs: specs, active: _active, allOpen: _allOpen,
                onJump: _go, onToggleAll: () { _manual = null; _toggleAll(); },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Hm.gutter, 14, Hm.gutter, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final s in specs) ...[
                    card(s),
                    const SizedBox(height: 12),
                    if (s.id == 'dosage') ...[const HmAdBanner(), const SizedBox(height: 12)],
                    if (s.id == 'brands') ...[
                      PromoSlider(placement: 'remedy', remedyId: r.id),
                      Padding(padding: const EdgeInsets.only(top: 6, bottom: 12), child: Text(l.promoNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
                    ],
                  ],
                ]),
              ),
            ),
          ],
        ),
        ),
      ),
      HmScrollTopPill(controller: _scroll, threshold: 900, top: _pinned + 8),
    ]);
  }
}

/// ============================================================
/// LEARN THE BASICS — a swipeable slider of topics with a page indicator
/// ============================================================
///
/// One card per topic (potency, how to take pellets, storage, when to see a doctor, searching, Materia Medica),
/// each in its own tone. The next card peeks in from the side so the slider reads as swipeable, and an
/// indicator under it shows the position (the active dot stretches into a pill, dots are tappable).
///
/// Cards open either a page (potency guide, disclaimer, search, settings) or a short bottom-sheet lesson.
/// Manual only: no autoplay, so nothing moves while someone is reading.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class _Topic {
  const _Topic({required this.icon, required this.tone, required this.badge, required this.title, required this.body, required this.open});
  final IconData icon;
  final (Color bg, Color ink) tone;
  final String badge, title, body;
  final void Function(BuildContext context) open;
}

class LearnSlider extends StatefulWidget {
  const LearnSlider({super.key});

  @override
  State<LearnSlider> createState() => _LearnSliderState();
}

class _LearnSliderState extends State<LearnSlider> {
  final _page = PageController(viewportFraction: .9);
  final _index = ValueNotifier<int>(0);

  @override
  void dispose() {
    _page.dispose();
    _index.dispose();
    super.dispose();
  }

  List<_Topic> _topics(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    return [
      _Topic(icon: Icons.bubble_chart_outlined, tone: (c.pe, c.peInk), badge: l.guideBadge, title: l.potencyGuideTitle, body: l.potencyGuideBody, open: (ctx) => ctx.push(AppRoutes.guide)),
      _Topic(
        icon: Icons.medication_outlined, tone: (c.ptBg, c.ptInk), badge: l.learnBadgeSteps, title: l.howToTake, body: l.learnPelletsBody,
        open: (ctx) => _lesson(ctx, l.howToTake, [(l.step1T, l.step1B), (l.step2T, l.step2B), (l.step3T, l.step3B), (l.step4T, l.step4B)], numbered: true),
      ),
      _Topic(
        icon: Icons.inventory_2_outlined, tone: (c.miBg, c.miInk), badge: l.learnBadgeStorage, title: l.learnStorageTitle, body: l.learnStorageBody,
        open: (ctx) => _lesson(ctx, l.learnStorageTitle, [('', l.storageTip1), ('', l.storageTip2), ('', l.storageTip3), ('', l.storageTip4)]),
      ),
      _Topic(icon: Icons.local_hospital_outlined, tone: (c.dg, c.dgInk), badge: l.learnBadgeSafety, title: l.learnDoctorTitle, body: l.learnDoctorBody, open: (ctx) => ctx.push(AppRoutes.disclaimer)),
      _Topic(icon: Icons.manage_search_rounded, tone: (c.am, c.amInk), badge: l.learnBadgeTip, title: l.learnSearchTitle, body: l.learnSearchBody, open: (ctx) => ctx.push(AppRoutes.search)),
      _Topic(icon: Icons.menu_book_outlined, tone: (c.noBg, c.noInk), badge: l.learnBadgeStudy, title: l.learnMateriaTitle, body: l.learnMateriaBody, open: (ctx) => ctx.go(AppRoutes.settings)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final topics = _topics(context);
    // Cards grow with the text size / taller Bangla script so a title and body never overflow.
    final textFactor = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.6);
    final height = 184 * textFactor + (context.bn ? 14 : 0);
    return Column(children: [
      SizedBox(
        height: height,
        child: PageView.builder(
          controller: _page,
          itemCount: topics.length,
          padEnds: false,
          onPageChanged: (i) {
            HapticFeedback.selectionClick();
            _index.value = i;
          },
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsetsDirectional.only(start: i == 0 ? Hm.gutter : 6, end: i == topics.length - 1 ? Hm.gutter : 6),
            child: Semantics(label: l.learnTopicOf(numL(context, i + 1), numL(context, topics.length)), container: true, child: _TopicCard(topic: topics[i])),
          ),
        ),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<int>(
        valueListenable: _index,
        builder: (context, current, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var k = 0; k < topics.length; k++)
            Semantics(
              button: true,
              selected: k == current,
              label: l.learnTopicOf(numL(context, k + 1), numL(context, topics.length)),
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _page.animateToPage(k, duration: context.motion(HmMotion.slow), curve: HmMotion.curve),
                // a 24 dp-tall hit area around a 7 dp dot
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  child: AnimatedContainer(
                    duration: context.motion(HmMotion.normal),
                    curve: HmMotion.curve,
                    width: k == current ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(color: k == current ? c.p : c.sf3, borderRadius: BorderRadius.circular(99)),
                  ),
                ),
              ),
            ),
        ]),
      ),
    ]);
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});
  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    final (bg, ink) = topic.tone;
    return HmCard(
      color: bg, border: bg, radius: 24, elevated: false,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      onTap: () => topic.open(context),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            HmBadge(topic.badge, bg: Colors.white.withValues(alpha: .6), ink: ink),
            const SizedBox(height: 10),
            Text(topic.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.25, color: ink)),
            const SizedBox(height: 5),
            Text(topic.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.4, color: ink)),
          ]),
        ),
        const SizedBox(width: 10),
        Icon(topic.icon, size: 54, color: ink.withValues(alpha: .45)),
      ]),
    );
  }
}

/// A short lesson in a bottom sheet: numbered steps (title + text) or plain bullet tips (empty title).
void _lesson(BuildContext context, String title, List<(String, String)> items, {bool numbered = false}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final c = context.hm;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 16),
          for (final (i, (t, b)) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (numbered)
                  Container(
                    width: 28, height: 28, alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.p, shape: BoxShape.circle),
                    child: Text(numL(context, i + 1), style: TextStyle(color: c.onp, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  )
                else
                  Container(margin: const EdgeInsets.fromLTRB(9, 8, 0, 0), width: 8, height: 8, decoration: BoxDecoration(color: c.p2, shape: BoxShape.circle)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (t.isNotEmpty) Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    Text(b, style: TextStyle(fontSize: 13.5, color: t.isEmpty ? c.ink : c.ink2, height: 1.5)),
                  ]),
                ),
              ]),
            ),
        ]),
      );
    },
  );
}

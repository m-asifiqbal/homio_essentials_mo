/// ============================================================
/// SEARCH INDEX — offline matching over the cached archive
/// ============================================================
///
/// Matches Latin, common and Bangla names, abbreviations, Banglish keys
/// ("arnika", "nuks vomika") and small typos. Pure Dart, no I/O.
/// Scoring: exact 1.0 › prefix ~0.9 › phonetic › word prefix 0.8 ›
/// substring 0.65 › typo (≤1–2 edits on the same-length prefix).
/// ============================================================
library;

import 'dart:math';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';

export 'package:homio_essentials/features/search/domain/entities/search_hit.dart';

class SearchIndex {
  SearchIndex(Archive a) {
    for (final r in a.remedies) {
      _add(HitKind.remedy, r.slug, [r.latin, r.abbr, r.en?.common, r.bn?.displayName, r.bn?.common, ...r.searchKeys], weight: r.curated ? 1.0 : 0.97);
    }
    for (final c in a.conditions) {
      _add(HitKind.condition, c.slug, [c.en?.name, c.bn?.name, ...?c.en?.keys, ...?c.bn?.keys], weight: 0.99);
    }
    for (final m in a.manufacturers) {
      _add(HitKind.manufacturer, m.id, [m.name, m.shortName], weight: 0.9);
    }
  }

  final _entries = <_Entry>[];

  void _add(HitKind kind, String id, List<String?> terms, {required double weight}) {
    for (final t in terms) {
      if (t == null || t.trim().isEmpty) continue;
      _entries.add(_Entry(kind, id, t, normalize(t), phonetic(normalize(t)), weight));
    }
  }

  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àáâäã]'), 'a').replaceAll(RegExp('[èéêë]'), 'e').replaceAll(RegExp('[ìíîï]'), 'i')
      .replaceAll(RegExp('[òóôöõ]'), 'o').replaceAll(RegExp('[ùúûü]'), 'u').replaceAll('æ', 'ae').replaceAll('œ', 'oe')
      .replaceAll(RegExp(r'[^\p{L}\p{N}\p{M}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Folds spelling variants so Banglish and Latin meet: arnika≈arnica, nuks≈nux, foos≈phos.
  static String phonetic(String s) {
    if (RegExp(r'[^\x00-\x7F]').hasMatch(s)) return s; // Bangla script: compare as typed
    var t = s
        .replaceAll('ph', 'f').replaceAll('ck', 'k').replaceAll('ch', 'k').replaceAll('c', 'k').replaceAll('q', 'k')
        .replaceAll('x', 'ks').replaceAll('y', 'i').replaceAll('z', 's').replaceAll('w', 'v')
        .replaceAll('oo', 'u').replaceAll('ee', 'i').replaceAll('ou', 'u').replaceAll('ae', 'e').replaceAll('oe', 'e')
        .replaceAll(RegExp(r'([bdgkpt])h'), r'$1');
    return t.replaceAllMapped(RegExp(r'(.)\1+'), (m) => m[1]!);
  }

  static int lev(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        cur[j] = min(min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1));
      }
      prev = cur;
    }
    return prev[b.length];
  }

  double _score(String q, String qp, _Entry e) {
    final n = e.norm, p = e.phon;
    if (n == q) return 1.0;
    if (n.startsWith(q)) return 0.92 - min(0.1, (n.length - q.length) * 0.004);
    if (p == qp) return 0.9;
    if (p.startsWith(qp) && qp.length >= 3) return 0.85;
    if (n.split(' ').any((w) => w.startsWith(q))) return 0.8;
    if (q.length >= 3 && n.contains(q)) return 0.65;
    if (qp.length >= 4) {
      var best = 0.0;
      for (final w in [p, ...p.split(' ')]) {
        final cut = w.length > qp.length ? w.substring(0, qp.length) : w;
        final d = lev(qp, cut);
        final ratio = 1 - d / max(qp.length, cut.length);
        if (d <= (qp.length >= 7 ? 2 : 1) && ratio > best) best = ratio;
      }
      if (best > 0) return 0.45 + best * 0.25;
    }
    return 0;
  }

  /// Ranked hits (best per item). Multi-word queries that match nothing fall back to their words.
  List<SearchHit> search(String query, {Set<HitKind>? kinds, int limit = 60}) {
    final q = normalize(query);
    if (q.isEmpty) return const [];
    final qp = phonetic(q);
    final best = <String, SearchHit>{};
    for (final e in _entries) {
      if (kinds != null && !kinds.contains(e.kind)) continue;
      final s = _score(q, qp, e) * e.weight;
      if (s <= 0) continue;
      final key = '${e.kind.name}:${e.id}';
      final prev = best[key];
      if (prev == null || s > prev.score) best[key] = SearchHit(e.kind, e.id, s, e.raw);
    }
    if (best.isEmpty && q.contains(' ')) {
      final merged = <String, SearchHit>{};
      for (final w in q.split(' ').where((w) => w.length >= 3)) {
        for (final h in search(w, kinds: kinds, limit: limit)) {
          final key = '${h.kind.name}:${h.id}';
          if ((merged[key]?.score ?? 0) < h.score * 0.8) merged[key] = SearchHit(h.kind, h.id, h.score * 0.8, h.matched);
        }
      }
      return (merged.values.toList()..sort((a, b) => b.score.compareTo(a.score))).take(limit).toList();
    }
    return (best.values.toList()..sort((a, b) => b.score.compareTo(a.score))).take(limit).toList();
  }

  /// "Did you mean …?" — only when [query] finds nothing good: the known name
  /// closest to one of its words (≤ 2 phonetic edits), or null.
  String? didYouMean(String query) {
    if ((search(query, limit: 1).firstOrNull?.score ?? 0) >= 0.6) return null;
    final words = normalize(query).split(' ').where((w) => w.length >= 4).toList();
    String? best;
    var bestD = 3;
    for (final w in words) {
      final wp = phonetic(w);
      for (final e in _entries) {
        for (final part in e.norm.split(' ')) {
          if (part.length < 4 || part == w || (part.length - w.length).abs() > 2) continue;
          final d = lev(wp, phonetic(part));
          if (d < bestD) {
            bestD = d;
            best = e.raw;
          }
        }
      }
    }
    return best;
  }
}

class _Entry {
  _Entry(this.kind, this.id, this.raw, this.norm, this.phon, this.weight);
  final HitKind kind;
  final String id, raw, norm, phon;
  final double weight;
}

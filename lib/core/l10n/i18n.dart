import 'package:flutter/widgets.dart';

import 'package:homio_essentials/l10n/app_localizations.dart';

export 'package:homio_essentials/l10n/app_localizations.dart';

extension LContext on BuildContext {
  L get l => L.of(this);
  bool get bn => Localizations.localeOf(this).languageCode == 'bn';
}

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// Numbers in Bangla digits when the app is in Bangla (৭১৬), otherwise as-is.
String numL(BuildContext c, Object n) =>
    c.bn ? '$n'.split('').map((ch) => int.tryParse(ch) != null ? _bnDigits[int.parse(ch)] : ch).join() : '$n';

String sizeL(BuildContext c, int bytes) {
  final mb = bytes / (1024 * 1024);
  return numL(c, mb >= 1 ? '${mb.toStringAsFixed(1)} MB' : '${(bytes / 1024).round()} KB');
}

extension LabelLookups on L {
  String kingdom(String? k) => switch (k) {
        'plant' => kingdom_plant,
        'mineral' => kingdom_mineral,
        'animal' => kingdom_animal,
        'nosode' => kingdom_nosode,
        'sarcode' => kingdom_sarcode,
        'imponderabilia' => kingdom_imponderabilia,
        _ => kingdom_other,
      };

  String relation(String t) => switch (t) {
        'complementary' => rel_complementary,
        'antidote' => rel_antidote,
        'inimical' => rel_inimical,
        'follows_well' => rel_follows_well,
        _ => rel_compare,
      };

  String book(String b) => switch (b) { 'allen' => book_allen, _ => book_boericke };

  String status(String s) => switch (s) {
        'needs_info' => status_needs_info,
        'approved' => status_approved,
        'merged' => status_merged,
        'rejected' => status_rejected,
        _ => status_new,
      };

  String accent(String a) => switch (a) { 'ocean' => accent_ocean, 'forest' => accent_forest, 'plum' => accent_plum, _ => accent_teal };

  String modeNote(String role) => switch (role) {
        'student' => modeNote_student,
        'practitioner' => modeNote_practitioner,
        _ => modeNote_general,
      };
}

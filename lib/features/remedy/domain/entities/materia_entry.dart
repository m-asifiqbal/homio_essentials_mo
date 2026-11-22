/// One section of a source book for a remedy (Boericke "Mind", Allen "Keynotes"…).
library;

import 'package:homio_essentials/core/utils/json.dart';

/// Book text is the original English (`locale` en); a few sections also have a Bangla translation (locale bn),
/// e.g. Boericke's dose notes shown on the dosage page.
class MateriaEntry {
  MateriaEntry.from(Json j)
      : book = j['source_book'], section = j['section'], body = j['body'], sourceUrl = j['source_url'], sort = j['sort_order'] ?? 0,
        locale = j['locale'] ?? 'en';
  final String book, section, body, locale;
  final String? sourceUrl;
  final int sort;
  bool get isEnglish => locale == 'en';

  Json toJson() => {'source_book': book, 'section': section, 'body': body, 'source_url': sourceUrl, 'sort_order': sort, 'locale': locale};
}

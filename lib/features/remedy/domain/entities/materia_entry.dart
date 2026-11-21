/// One section of a source book for a remedy (Boericke "Mind", Allen "Keynotes"…).
library;

import 'package:homio_essentials/core/utils/json.dart';

class MateriaEntry {
  MateriaEntry.from(Json j) : book = j['source_book'], section = j['section'], body = j['body'], sourceUrl = j['source_url'], sort = j['sort_order'] ?? 0;
  final String book, section, body;
  final String? sourceUrl;
  final int sort;

  Json toJson() => {'source_book': book, 'section': section, 'body': body, 'source_url': sourceUrl, 'sort_order': sort};
}

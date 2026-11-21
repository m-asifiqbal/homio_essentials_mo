/// A medicine request this device sent, as returned by `get_my_requests`.
library;

import 'package:homio_essentials/core/utils/json.dart';

class MyRequest {
  MyRequest.from(Json j)
      : code = j['code'], kind = j['kind'], title = j['title'], status = j['status'], note = j['reviewer_note'],
        linkedRemedyId = j['linked_remedy_id'], createdAt = DateTime.tryParse('${j['created_at']}');
  final String code, kind, status;
  final String? title, note, linkedRemedyId;
  final DateTime? createdAt;
}

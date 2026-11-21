/// A paid promotion banner managed in the admin app (`promotions` table).
library;

import 'package:homio_essentials/core/archive/domain/entities/models.dart';

class Promotion {
  Promotion.from(Json j)
      : id = j['id'], advertiser = j['advertiser'], title = I18n.from(j['title']), imagePath = j['image_path'], imageBnPath = j['image_bn_path'],
        tapAction = j['tap_action'] ?? 'link', tapValue = j['tap_value'], placements = strs(j['placements']), remedyIds = strs(j['remedy_ids']);
  final String id, advertiser, imagePath, tapAction, tapValue;
  final String? imageBnPath;
  final I18n title;
  final List<String> placements, remedyIds;

  bool showsOn(String placement, {String? remedyId}) =>
      placements.contains(placement) && (remedyId == null || remedyIds.isEmpty || remedyIds.contains(remedyId));
}

/// ============================================================
/// PROMOTIONS REPOSITORY (contract) — live paid banners + their analytics
/// ============================================================
library;

import 'package:homio_essentials/features/promotions/domain/entities/promotion.dart';

abstract interface class PromotionsRepository {
  /// Promotions live right now (published and inside their date window).
  Future<List<Promotion>> live();

  String imageUrl(String path);

  /// Records an impression or tap; never throws (analytics must not break the UI).
  Future<void> log(String promotionId, {required String event, required String placement, required String locale});
}

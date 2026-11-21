/// ============================================================
/// PROMOTIONS REPOSITORY (impl) — PostgREST + public storage bucket
/// ============================================================
library;

import 'package:homio_essentials/core/config/env.dart';
import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/core/utils/app_logger.dart';
import 'package:homio_essentials/features/promotions/domain/entities/promotion.dart';
import 'package:homio_essentials/features/promotions/domain/repository/promotions_repository.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  PromotionsRepositoryImpl(this.api);
  final PostgrestApi api;

  @override
  Future<List<Promotion>> live() async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await api.select('promotions',
        columns: 'id,advertiser,title,image_path,image_bn_path,tap_action,tap_value,placements,remedy_ids',
        filters: {'starts_at': 'lte.$now', 'ends_at': 'gte.$now'},
        order: const ['sort_order.asc']);
    return rows.map(Promotion.from).toList();
  }

  @override
  String imageUrl(String path) => Env.storagePublicUrl('promotions', path);

  @override
  Future<void> log(String promotionId, {required String event, required String placement, required String locale}) async {
    try {
      await api.insert('promotion_events', {'promotion_id': promotionId, 'event': event, 'placement': placement, 'locale': locale});
    } catch (e) {
      AppLogger.d('promotion event not recorded: $e');
    }
  }
}

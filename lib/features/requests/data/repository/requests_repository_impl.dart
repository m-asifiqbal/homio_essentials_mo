/// ============================================================
/// REQUESTS REPOSITORY (impl) — inserts go to the admin review queue
/// ============================================================
library;

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/features/requests/domain/entities/my_request.dart';
import 'package:homio_essentials/features/requests/domain/repository/requests_repository.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  RequestsRepositoryImpl(this.api);
  final PostgrestApi api;

  @override
  Future<void> submitRequest({required String kind, required Map<String, dynamic> payload, required String role, required String deviceId}) =>
      api.insert('medicine_requests', {'kind': kind, 'payload': payload, 'requester_role': role, 'device_id': deviceId});

  @override
  Future<void> reportError({required String entityType, String? entityId, required String message, required String deviceId}) =>
      api.insert('content_reports', {'entity_type': entityType, 'entity_id': entityId, 'message': message, 'device_id': deviceId});

  @override
  Future<List<MyRequest>> myRequests(String deviceId) async {
    final rows = (await api.rpc('get_my_requests', params: {'p_device_id': deviceId}) as List?) ?? const [];
    return rows.map((e) => MyRequest.from(Map<String, dynamic>.from(e as Map))).toList();
  }
}

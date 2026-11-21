/// ============================================================
/// REQUESTS REPOSITORY (contract) — medicine requests and error reports
/// ============================================================
///
/// No accounts: a random per-install device id keys "My requests"
/// (the `get_my_requests` RPC only returns rows with that id).
/// ============================================================
library;

import 'package:homio_essentials/features/requests/domain/entities/my_request.dart';

abstract interface class RequestsRepository {
  Future<void> submitRequest({required String kind, required Map<String, dynamic> payload, required String role, required String deviceId});
  Future<void> reportError({required String entityType, String? entityId, required String message, required String deviceId});
  Future<List<MyRequest>> myRequests(String deviceId);
}

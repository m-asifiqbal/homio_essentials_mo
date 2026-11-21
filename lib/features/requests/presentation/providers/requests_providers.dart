/// ============================================================
/// REQUESTS PROVIDERS — submit a request / report, list my requests
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/features/requests/domain/entities/my_request.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

final myRequestsProvider = FutureProvider.autoDispose<List<MyRequest>>((ref) {
  final device = ref.watch(settingsProvider.select((s) => s.deviceId));
  return ref.watch(requestsRepositoryProvider).myRequests(device);
});

enum SubmitStatus { idle, sending, sent, failed }

/// Sends one request or report; the screen only renders [SubmitStatus].
class SubmitController extends Notifier<SubmitStatus> {
  @override
  SubmitStatus build() => SubmitStatus.idle;

  Future<bool> sendRequest({required String kind, required Map<String, dynamic> payload, required Role role}) => _run(() =>
      ref.read(requestsRepositoryProvider).submitRequest(kind: kind, payload: payload, role: role.name, deviceId: ref.read(settingsProvider).deviceId));

  Future<bool> sendReport({required String message, String entityType = 'other', String? entityId}) => _run(() =>
      ref.read(requestsRepositoryProvider).reportError(entityType: entityType, entityId: entityId, message: message, deviceId: ref.read(settingsProvider).deviceId));

  Future<bool> _run(Future<void> Function() job) async {
    state = SubmitStatus.sending;
    try {
      await job();
      state = SubmitStatus.sent;
      ref.invalidate(myRequestsProvider);
      return true;
    } catch (_) {
      state = SubmitStatus.failed;
      return false;
    }
  }
}

final submitControllerProvider = NotifierProvider.autoDispose<SubmitController, SubmitStatus>(SubmitController.new);

/// Live paid promotions (refetched when the app restarts).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/features/promotions/domain/entities/promotion.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

final livePromotionsProvider = FutureProvider<List<Promotion>>((ref) => ref.watch(promotionsRepositoryProvider).live());

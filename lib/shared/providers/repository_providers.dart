/// ============================================================
/// REPOSITORY PROVIDERS — one provider per repository contract
/// ============================================================
///
/// Presentation reads the *contract* and never sees Dio. Tests override
/// [postgrestProvider] / [cacheStoreProvider] for an isolated graph.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/data/datasource/archive_local_datasource.dart';
import 'package:homio_essentials/core/archive/data/datasource/archive_remote_datasource.dart';
import 'package:homio_essentials/core/archive/data/repository/archive_repository_impl.dart';
import 'package:homio_essentials/core/archive/domain/repository/archive_repository.dart';
import 'package:homio_essentials/features/promotions/data/repository/promotions_repository_impl.dart';
import 'package:homio_essentials/features/promotions/domain/repository/promotions_repository.dart';
import 'package:homio_essentials/features/remedy/data/repository/materia_repository_impl.dart';
import 'package:homio_essentials/features/remedy/domain/repository/materia_repository.dart';
import 'package:homio_essentials/features/requests/data/repository/requests_repository_impl.dart';
import 'package:homio_essentials/features/requests/domain/repository/requests_repository.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';

final archiveLocalDataSourceProvider = Provider((ref) => ArchiveLocalDataSource(ref.watch(cacheStoreProvider)));

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) => ArchiveRepositoryImpl(
      remote: ArchiveRemoteDataSource(ref.watch(postgrestProvider)),
      local: ref.watch(archiveLocalDataSourceProvider),
    ));

final materiaRepositoryProvider = Provider<MateriaRepository>(
    (ref) => MateriaRepositoryImpl(api: ref.watch(postgrestProvider), local: ref.watch(archiveLocalDataSourceProvider)));

final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) => PromotionsRepositoryImpl(ref.watch(postgrestProvider)));

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) => RequestsRepositoryImpl(ref.watch(postgrestProvider)));

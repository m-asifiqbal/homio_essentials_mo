/// ============================================================
/// REPOSITORY PROVIDERS — one provider per repository contract
/// ============================================================
///
/// Presentation reads the *contract* and never sees Dio. Tests override
/// [postgrestProvider] for an isolated graph.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/archive/data/datasource/archive_remote_datasource.dart';
import 'package:homio_essentials/core/archive/data/repository/archive_repository_impl.dart';
import 'package:homio_essentials/core/archive/domain/repository/archive_repository.dart';
import 'package:homio_essentials/core/connection/data/repository/connection_repository_impl.dart';
import 'package:homio_essentials/core/connection/domain/repository/connection_repository.dart';
import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/features/promotions/data/repository/promotions_repository_impl.dart';
import 'package:homio_essentials/features/promotions/domain/repository/promotions_repository.dart';
import 'package:homio_essentials/features/remedy/data/repository/materia_repository_impl.dart';
import 'package:homio_essentials/features/remedy/domain/repository/materia_repository.dart';
import 'package:homio_essentials/features/requests/data/repository/requests_repository_impl.dart';
import 'package:homio_essentials/features/requests/domain/repository/requests_repository.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) => ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(ref.watch(postgrestProvider))));

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) => ConnectionRepositoryImpl(api: PostgrestApi(ref.watch(probeDioProvider))));

final materiaRepositoryProvider = Provider<MateriaRepository>((ref) => MateriaRepositoryImpl(api: ref.watch(postgrestProvider)));

final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) => PromotionsRepositoryImpl(ref.watch(postgrestProvider)));

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) => RequestsRepositoryImpl(ref.watch(postgrestProvider)));

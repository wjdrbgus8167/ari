// lib/providers/chart_providers.dart

import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/chart_remote_data_source.dart';
import 'package:ari/data/repositories/chart_repository_impl.dart';
import 'package:ari/domain/repositories/chart_repository.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';

// Chart RemoteDataSource
final chartRemoteDataSourceProvider = Provider<ChartRemoteDataSource>((ref) {
  return ChartRemoteDataSource(dio: ref.watch(dioProvider));
});

// Chart Repository
final chartRepositoryProvider = Provider<IChartRepository>((ref) {
  return ChartRepositoryImpl(
    remoteDataSource: ref.watch(chartRemoteDataSourceProvider),
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  );
});

// GetCharts UseCase
final getChartsUseCaseProvider = Provider<GetChartsUseCase>((ref) {
  return GetChartsUseCase(ref.watch(chartRepositoryProvider));
});

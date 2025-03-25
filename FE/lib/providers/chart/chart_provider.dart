import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/chart_remote_data_source.dart';
import 'package:ari/data/repositories/chart_repository_impl.dart';
import 'package:ari/domain/repositories/chart_repository.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';
import 'package:ari/core/constants/app_constants.dart'; // baseUrl

// Chart RemoteDataSource
// 서버에서 차트데이터를 가져옴
final chartRemoteDataSourceProvider = Provider<ChartRemoteDataSource>((ref) {
  return ChartRemoteDataSource(dio: ref.watch(dioProvider));
});

// Chart Repository
// 차트데이터를 가져오는 레포지토리
final chartRepositoryProvider = Provider<IChartRepository>((ref) {
  return ChartRepositoryImpl(
    remoteDataSource: ref.watch(chartRemoteDataSourceProvider),
    baseUrl: baseUrl,
  );
});

// GetCharts UseCase
// 차트 데이터를 가져오는 유스케이스
final getChartsUseCaseProvider = Provider<GetChartsUseCase>((ref) {
  return GetChartsUseCase(ref.watch(chartRepositoryProvider));
});

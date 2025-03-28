// 데이터 소스 Provider
import 'package:ari/data/datasources/track_remote_datasource.dart';
import 'package:ari/data/repositories/track_repository.dart';
import 'package:ari/domain/usecases/track_detail_usecase.dart';
import 'package:ari/presentation/viewmodels/track/track_detail_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';

final trackDataSourceProvider = Provider((ref) {
  return TrackMockDataSourceImpl(
    dio: ref.watch(dioProvider),
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  ); // 필요한 경우 파라미터 전달
});

// 리포지토리 Provider
final trackRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(trackDataSourceProvider);
  return TrackRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider
final getTrackDetailProvider = Provider((ref) {
  final repository = ref.watch(trackRepositoryProvider);
  return GetTrackDetail(repository);
});

// ViewModel Provider
final trackDetailViewModelProvider =
    StateNotifierProvider<TrackDetailViewModel, TrackDetailState>((ref) {
      final getTrackDetail = ref.watch(getTrackDetailProvider);
      return TrackDetailViewModel(getTrackDetail: getTrackDetail);
    });

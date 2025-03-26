// 데이터 소스 Provider
import 'package:ari/data/datasources/streaming_remote_datasource.dart';
import 'package:ari/data/repositories/streaming_repository.dart';
import 'package:ari/domain/usecases/get_streaming_usecase.dart';
import 'package:ari/presentation/viewmodels/streaming_log_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';

final streamingDataSourceProvider = Provider((ref) {
  return MockStreamingDataSourceImpl(
    dio: ref.watch(dioProvider),
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://ari-music.duckdns.org',
    ),
  );
});

// 리포지토리 Provider
final streamingRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(streamingDataSourceProvider);
  return StreamingRepositoryImpl(dataSource: dataSource);
});

// UseCase Provider
final getStreamingLogByTrackIdProvider = Provider((ref) {
  final repository = ref.watch(streamingRepositoryProvider);
  return GetStreamingLogByTrackId(repository);
});

// ViewModel Provider
final streamingLogViewModelProvider =
    StateNotifierProvider<StreamingLogViewmodel, StreamingState>((ref) {
      final getStreamingLogByTrackId = ref.watch(
        getStreamingLogByTrackIdProvider,
      );
      return StreamingLogViewmodel(
        getStreamingLogByTrackId: getStreamingLogByTrackId,
      );
    });

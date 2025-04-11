import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/my_channel/fantalk_remote_datasource.dart';
import '../../data/datasources/my_channel/fantalk_remote_datasource_impl.dart';
import '../../data/repositories/my_channel/fantalk_repository_impl.dart';
import '../../domain/repositories/my_channel/fantalk_repository.dart';
import '../../domain/usecases/my_channel/fantalk_usecases.dart';
import '../../presentation/viewmodels/my_channel/fantalk_viewmodel.dart';
import '../global_providers.dart';

/// 팬톡 원격 데이터소스 provider
final fantalkRemoteDataSourceProvider = Provider<FantalkRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return FantalkRemoteDataSourceImpl(apiClient: apiClient);
});

/// 팬톡 레포지토리 provider
final fantalkRepositoryProvider = Provider<FantalkRepository>((ref) {
  final remoteDataSource = ref.watch(fantalkRemoteDataSourceProvider);
  return FantalkRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// 팬톡 목록 조회 유스케이스 provider
final getFanTalksUseCaseProvider = Provider<GetFanTalksUseCase>((ref) {
  final repository = ref.watch(fantalkRepositoryProvider);
  return GetFanTalksUseCase(repository);
});

/// 팬톡 생성 유스케이스 provider
final createFantalkUseCaseProvider = Provider<CreateFantalkUseCase>((ref) {
  final repository = ref.watch(fantalkRepositoryProvider);
  return CreateFantalkUseCase(repository);
});

/// 팬톡 상태 관리 provider
final fantalkProvider = StateNotifierProvider<FantalkNotifier, FantalkState>((
  ref,
) {
  final getFanTalksUseCase = ref.watch(getFanTalksUseCaseProvider);
  final createFantalkUseCase = ref.watch(createFantalkUseCaseProvider);

  return FantalkNotifier(
    getFanTalksUseCase: getFanTalksUseCase,
    createFantalkUseCase: createFantalkUseCase,
  );
});

/// 선택된 트랙 ID 프로바이더 (팬톡 생성시 사용)
final selectedTrackIdProvider = StateProvider<int?>((ref) => null);

/// 팬톡 채널 ID 프로바이더 (현재 선택된 팬톡 채널)
final currentFantalkChannelIdProvider = StateProvider<String?>((ref) => null);

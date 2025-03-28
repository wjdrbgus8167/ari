import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/datasources/my_channel/my_channel_remote_datasource.dart';
import '../data/datasources/my_channel/my_channel_remote_datasource_impl.dart';
import '../data/repositories/my_channel/my_channel_repository_impl.dart';
import '../domain/repositories/my_channel/my_channel_repository.dart';
import '../domain/usecases/my_channel/my_channel_usecases.dart';
import '../presentation/viewmodels/my_channel_viewmodel.dart';

/// TODO: 토큰 provider - 추후 Secure Storage에서 토큰을 가져올 예정!!!!!!!
final authTokenProvider = Provider<String>((ref) {
  // 이 부분 Secure Storage에서 가져오기!!!!!
  return 'dummy-token';
});

/// Dio HTTP 클라이언트 provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// 나의 채널 원격 데이터 소스 provider
final myChannelRemoteDataSourceProvider = Provider<MyChannelRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final token = ref.watch(authTokenProvider);
  
  return MyChannelRemoteDataSourceImpl(
    dio: dio,
    token: token,
  );
});

/// 나의 채널 repository provider
final myChannelRepositoryProvider = Provider<MyChannelRepository>((ref) {
  final remoteDataSource = ref.watch(myChannelRemoteDataSourceProvider);
  
  return MyChannelRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// UseCase provider
final getChannelInfoUseCaseProvider = Provider<GetChannelInfoUseCase>((ref) {
  return GetChannelInfoUseCase(ref.watch(myChannelRepositoryProvider));
});

final followMemberUseCaseProvider = Provider<FollowMemberUseCase>((ref) {
  return FollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final unfollowMemberUseCaseProvider = Provider<UnfollowMemberUseCase>((ref) {
  return UnfollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final getArtistAlbumsUseCaseProvider = Provider<GetArtistAlbumsUseCase>((ref) {
  return GetArtistAlbumsUseCase(ref.watch(myChannelRepositoryProvider));
});

final getArtistNoticesUseCaseProvider = Provider<GetArtistNoticesUseCase>((ref) {
  return GetArtistNoticesUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFanTalksUseCaseProvider = Provider<GetFanTalksUseCase>((ref) {
  return GetFanTalksUseCase(ref.watch(myChannelRepositoryProvider));
});

final getPublicPlaylistsUseCaseProvider = Provider<GetPublicPlaylistsUseCase>((ref) {
  return GetPublicPlaylistsUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFollowersUseCaseProvider = Provider<GetFollowersUseCase>((ref) {
  return GetFollowersUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFollowingsUseCaseProvider = Provider<GetFollowingsUseCase>((ref) {
  return GetFollowingsUseCase(ref.watch(myChannelRepositoryProvider));
});

/// 나의 채널 ViewModel provider
final myChannelProvider = StateNotifierProvider<MyChannelNotifier, MyChannelState>((ref) {
  return MyChannelNotifier(
    getChannelInfoUseCase: ref.watch(getChannelInfoUseCaseProvider),
    followMemberUseCase: ref.watch(followMemberUseCaseProvider),
    unfollowMemberUseCase: ref.watch(unfollowMemberUseCaseProvider),
    getArtistAlbumsUseCase: ref.watch(getArtistAlbumsUseCaseProvider),
    getArtistNoticesUseCase: ref.watch(getArtistNoticesUseCaseProvider),
    getFanTalksUseCase: ref.watch(getFanTalksUseCaseProvider),
    getPublicPlaylistsUseCase: ref.watch(getPublicPlaylistsUseCaseProvider),
    getFollowersUseCase: ref.watch(getFollowersUseCaseProvider),
    getFollowingsUseCase: ref.watch(getFollowingsUseCaseProvider),
  );
});
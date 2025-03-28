import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth/auth_providers.dart'; // 인증 관련 provider
import '../providers/global_providers.dart'; // dioProvider 등 전역 provider 참조용

// datasource
import '../data/datasources/my_channel/my_channel_remote_datasource.dart';
import '../data/datasources/my_channel/my_channel_remote_datasource_impl.dart';
import '../data/datasources/my_channel/artist_notice_remote_datasource.dart';
import '../data/datasources/my_channel/artist_notice_remote_datasource_impl.dart';

// repository
import '../data/repositories/my_channel/my_channel_repository_impl.dart';
import '../data/repositories/my_channel/artist_notice_repository_impl.dart';
import '../domain/repositories/my_channel/my_channel_repository.dart';
import '../domain/repositories/my_channel/artist_notice_repository.dart';

// usecase
import '../domain/usecases/my_channel/my_channel_usecases.dart' as channel;
import '../domain/usecases/my_channel/artist_notice_usecases.dart' as notice;

// viewmodel
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
final myChannelRemoteDataSourceProvider = Provider<MyChannelRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  final token = ref.watch(authTokenProvider);

  return MyChannelRemoteDataSourceImpl(dio: dio, token: token);
});

/// 나의 채널 repository provider
final myChannelRepositoryProvider = Provider<MyChannelRepository>((ref) {
  final remoteDataSource = ref.watch(myChannelRemoteDataSourceProvider);

  return MyChannelRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// UseCase provider
final getChannelInfoUseCaseProvider = Provider<channel.GetChannelInfoUseCase>((
  ref,
) {
  return channel.GetChannelInfoUseCase(ref.watch(myChannelRepositoryProvider));
});

final followMemberUseCaseProvider = Provider<channel.FollowMemberUseCase>((
  ref,
) {
  return channel.FollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final unfollowMemberUseCaseProvider = Provider<channel.UnfollowMemberUseCase>((
  ref,
) {
  return channel.UnfollowMemberUseCase(ref.watch(myChannelRepositoryProvider));
});

final getArtistAlbumsUseCaseProvider = Provider<channel.GetArtistAlbumsUseCase>(
  (ref) {
    return channel.GetArtistAlbumsUseCase(
      ref.watch(myChannelRepositoryProvider),
    );
  },
);

// 채널용 공지사항 provider
final getChannelRecentNoticesUseCaseProvider =
    Provider<channel.GetChannelRecentNoticesUseCase>((ref) {
      return channel.GetChannelRecentNoticesUseCase(
        ref.watch(myChannelRepositoryProvider),
      );
    });

final getFanTalksUseCaseProvider = Provider<channel.GetFanTalksUseCase>((ref) {
  return channel.GetFanTalksUseCase(ref.watch(myChannelRepositoryProvider));
});

final getPublicPlaylistsUseCaseProvider =
    Provider<channel.GetPublicPlaylistsUseCase>((ref) {
      return channel.GetPublicPlaylistsUseCase(
        ref.watch(myChannelRepositoryProvider),
      );
    });

final getFollowersUseCaseProvider = Provider<channel.GetFollowersUseCase>((
  ref,
) {
  return channel.GetFollowersUseCase(ref.watch(myChannelRepositoryProvider));
});

final getFollowingsUseCaseProvider = Provider<channel.GetFollowingsUseCase>((
  ref,
) {
  return channel.GetFollowingsUseCase(ref.watch(myChannelRepositoryProvider));
});

/// 아티스트 공지사항 전용 provider
final getArtistNoticesUseCaseProvider =
    Provider<notice.GetArtistNoticesUseCase>((ref) {
      final repository = ref.watch(artistNoticeRepositoryProvider);
      return notice.GetArtistNoticesUseCase(repository);
    });

final getArtistNoticeDetailUseCaseProvider =
    Provider<notice.GetArtistNoticeDetailUseCase>((ref) {
      final repository = ref.watch(artistNoticeRepositoryProvider);
      return notice.GetArtistNoticeDetailUseCase(repository);
    });

final createArtistNoticeUseCaseProvider =
    Provider<notice.CreateArtistNoticeUseCase>((ref) {
      final repository = ref.watch(artistNoticeRepositoryProvider);
      return notice.CreateArtistNoticeUseCase(repository);
    });

// 아티스트 공지사항 데이터소스 provider
final artistNoticeRemoteDataSourceProvider =
    Provider<ArtistNoticeRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return ArtistNoticeRemoteDataSourceImpl(dio: dio);
    });

// 아티스트 공지사항 repository provider
final artistNoticeRepositoryProvider = Provider<ArtistNoticeRepository>((ref) {
  final remoteDataSource = ref.watch(artistNoticeRemoteDataSourceProvider);
  return ArtistNoticeRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// 나의 채널 ViewModel provider
final myChannelProvider =
    StateNotifierProvider<MyChannelNotifier, MyChannelState>((ref) {
      return MyChannelNotifier(
        getChannelInfoUseCase: ref.watch(getChannelInfoUseCaseProvider),
        followMemberUseCase: ref.watch(followMemberUseCaseProvider),
        unfollowMemberUseCase: ref.watch(unfollowMemberUseCaseProvider),
        getArtistAlbumsUseCase: ref.watch(getArtistAlbumsUseCaseProvider),
        getArtistNoticesUseCase: ref.watch(
          getChannelRecentNoticesUseCaseProvider,
        ),
        getFanTalksUseCase: ref.watch(getFanTalksUseCaseProvider),
        getPublicPlaylistsUseCase: ref.watch(getPublicPlaylistsUseCaseProvider),
        getFollowersUseCase: ref.watch(getFollowersUseCaseProvider),
        getFollowingsUseCase: ref.watch(getFollowingsUseCaseProvider),

        getArtistNoticeDetailUseCase: ref.watch(
          getArtistNoticeDetailUseCaseProvider,
        ),
        createArtistNoticeUseCase: ref.watch(createArtistNoticeUseCaseProvider),
      );
    });

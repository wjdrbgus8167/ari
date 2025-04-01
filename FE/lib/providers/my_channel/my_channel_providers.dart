import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/auth_interceptor.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_providers.dart'; // 인증 관련 provider
import '../global_providers.dart'; // dioProvider 등 전역 provider 참조용

// datasource
import '../../data/datasources/my_channel/my_channel_remote_datasource.dart';
import '../../data/datasources/my_channel/my_channel_remote_datasource_impl.dart';
import '../../data/datasources/my_channel/artist_notice_remote_datasource.dart';
import '../../data/datasources/my_channel/artist_notice_remote_datasource_impl.dart';

// repository
import '../../data/repositories/my_channel/my_channel_repository_impl.dart';
import '../../data/repositories/my_channel/artist_notice_repository_impl.dart';
import '../../domain/repositories/my_channel/my_channel_repository.dart';
import '../../domain/repositories/my_channel/artist_notice_repository.dart';

// usecase
import '../../domain/usecases/my_channel/my_channel_usecases.dart' as channel;
import '../../domain/usecases/my_channel/artist_notice_usecases.dart' as notice;

// viewmodel
import '../../presentation/viewmodels/my_channel/my_channel_viewmodel.dart';

/// 채널 기능용 Dio 인스턴스 - 인증 인터셉터 포함
final channelDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 인증 인터셉터 추가
  final authInterceptor = AuthInterceptor(
    refreshTokensUseCase: ref.watch(refreshTokensUseCaseProvider),
    getAuthStatusUseCase: ref.watch(getAuthStatusUseCaseProvider),
    getTokensUseCase: ref.watch(getTokensUseCaseProvider),
    dio: dio,
  );

  dio.interceptors.add(authInterceptor);

  // 로깅 인터셉터 (디버그 모드에서만)
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
});

/// 나의 채널 원격 데이터 소스 provider
final myChannelRemoteDataSourceProvider = Provider<MyChannelRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(channelDioProvider);
  return MyChannelRemoteDataSourceImpl(dio: dio);
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
      final dio = ref.watch(channelDioProvider);
      return ArtistNoticeRemoteDataSourceImpl(
        dio: dio,
        getTokensUseCase: ref.watch(getTokensUseCaseProvider),
      );
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

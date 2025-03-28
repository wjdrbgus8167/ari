import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // MultipartFile 사용
import '../../core/exceptions/failure.dart';
import '../../data/models/my_channel/channel_info.dart';
import '../../data/models/my_channel/artist_album.dart';
import '../../data/models/my_channel/artist_notice.dart';
import '../../data/models/my_channel/fantalk.dart';
import '../../data/models/my_channel/public_playlist.dart';
import '../../data/models/my_channel/neighbor.dart';
import '../../domain/usecases/my_channel/my_channel_usecases.dart';
import '../../domain/usecases/my_channel/artist_notice_usecases.dart' as notice;

/// 나의 채널 데이터 로딩 상태
enum MyChannelStatus { initial, loading, success, error }

/// 나의 채널 화면 상태 클래스
class MyChannelState {
  final MyChannelStatus channelInfoStatus;
  final MyChannelStatus artistAlbumsStatus;
  final MyChannelStatus artistNoticesStatus;
  final MyChannelStatus fanTalksStatus;
  final MyChannelStatus publicPlaylistsStatus;
  final MyChannelStatus followersStatus;
  final MyChannelStatus followingsStatus;
  final MyChannelStatus artistNoticeDetailStatus;
  final MyChannelStatus createNoticeStatus;

  final ChannelInfo? channelInfo;
  final List<ArtistAlbum>? artistAlbums;
  final ArtistNoticeResponse? artistNotices;
  final FanTalkResponse? fanTalks;
  final PublicPlaylistResponse? publicPlaylists;
  final FollowerResponse? followers;
  final FollowingResponse? followings;
  final ArtistNotice? artistNoticeDetail;

  final Failure? error;

  MyChannelState({
    this.channelInfoStatus = MyChannelStatus.initial,
    this.artistAlbumsStatus = MyChannelStatus.initial,
    this.artistNoticesStatus = MyChannelStatus.initial,
    this.fanTalksStatus = MyChannelStatus.initial,
    this.publicPlaylistsStatus = MyChannelStatus.initial,
    this.followersStatus = MyChannelStatus.initial,
    this.followingsStatus = MyChannelStatus.initial,
    this.artistNoticeDetailStatus = MyChannelStatus.initial,
    this.createNoticeStatus = MyChannelStatus.initial,

    this.channelInfo,
    this.artistAlbums,
    this.artistNotices,
    this.fanTalks,
    this.publicPlaylists,
    this.followers,
    this.followings,
    this.artistNoticeDetail,

    this.error,
  });

  /// 상태 복사 메서드
  MyChannelState copyWith({
    MyChannelStatus? channelInfoStatus,
    MyChannelStatus? artistAlbumsStatus,
    MyChannelStatus? artistNoticesStatus,
    MyChannelStatus? fanTalksStatus,
    MyChannelStatus? publicPlaylistsStatus,
    MyChannelStatus? followersStatus,
    MyChannelStatus? followingsStatus,
    MyChannelStatus? artistNoticeDetailStatus,
    MyChannelStatus? createNoticeStatus,

    ChannelInfo? channelInfo,
    List<ArtistAlbum>? artistAlbums,
    ArtistNoticeResponse? artistNotices,
    FanTalkResponse? fanTalks,
    PublicPlaylistResponse? publicPlaylists,
    FollowerResponse? followers,
    FollowingResponse? followings,
    ArtistNotice? artistNoticeDetail,

    Failure? error,
  }) {
    return MyChannelState(
      channelInfoStatus: channelInfoStatus ?? this.channelInfoStatus,
      artistAlbumsStatus: artistAlbumsStatus ?? this.artistAlbumsStatus,
      artistNoticesStatus: artistNoticesStatus ?? this.artistNoticesStatus,
      fanTalksStatus: fanTalksStatus ?? this.fanTalksStatus,
      publicPlaylistsStatus:
          publicPlaylistsStatus ?? this.publicPlaylistsStatus,
      followersStatus: followersStatus ?? this.followersStatus,
      followingsStatus: followingsStatus ?? this.followingsStatus,
      artistNoticeDetailStatus:
          artistNoticeDetailStatus ?? this.artistNoticeDetailStatus,
      createNoticeStatus: createNoticeStatus ?? this.createNoticeStatus,

      channelInfo: channelInfo ?? this.channelInfo,
      artistAlbums: artistAlbums ?? this.artistAlbums,
      artistNotices: artistNotices ?? this.artistNotices,
      fanTalks: fanTalks ?? this.fanTalks,
      publicPlaylists: publicPlaylists ?? this.publicPlaylists,
      followers: followers ?? this.followers,
      followings: followings ?? this.followings,
      artistNoticeDetail: artistNoticeDetail ?? this.artistNoticeDetail,

      error: error ?? this.error,
    );
  }

  /// 아티스트인지 확인하는 getter
  /// 앨범!이 있으면 아티스트로 판단
  bool get isArtist {
    return artistAlbums != null && artistAlbums!.isNotEmpty;
  }
}

/// 나의 채널 뷰모델 제공자
/// Riverpod로 나의 채널 상태 관리
class MyChannelNotifier extends StateNotifier<MyChannelState> {
  final GetChannelInfoUseCase getChannelInfoUseCase;
  final FollowMemberUseCase followMemberUseCase;
  final UnfollowMemberUseCase unfollowMemberUseCase;
  final GetArtistAlbumsUseCase getArtistAlbumsUseCase;
  final GetChannelRecentNoticesUseCase getArtistNoticesUseCase;
  final GetFanTalksUseCase getFanTalksUseCase;
  final GetPublicPlaylistsUseCase getPublicPlaylistsUseCase;
  final GetFollowersUseCase getFollowersUseCase;
  final GetFollowingsUseCase getFollowingsUseCase;
  final notice.GetArtistNoticeDetailUseCase getArtistNoticeDetailUseCase;
  final notice.CreateArtistNoticeUseCase createArtistNoticeUseCase;

  MyChannelNotifier({
    required this.getChannelInfoUseCase,
    required this.followMemberUseCase,
    required this.unfollowMemberUseCase,
    required this.getArtistAlbumsUseCase,
    required this.getArtistNoticesUseCase,
    required this.getFanTalksUseCase,
    required this.getPublicPlaylistsUseCase,
    required this.getFollowersUseCase,
    required this.getFollowingsUseCase,
    required this.getArtistNoticeDetailUseCase,
    required this.createArtistNoticeUseCase,
  }) : super(MyChannelState());

  /// 채널 정보 로딩
  Future<void> loadChannelInfo(String memberId) async {
    state = state.copyWith(channelInfoStatus: MyChannelStatus.loading);

    final result = await getChannelInfoUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            channelInfoStatus: MyChannelStatus.error,
            error: failure,
          ),
      (channelInfo) =>
          state = state.copyWith(
            channelInfoStatus: MyChannelStatus.success,
            channelInfo: channelInfo,
          ),
    );
  }

  /// 회원 팔로우
  Future<void> followMember(String memberId) async {
    final result = await followMemberUseCase.execute(memberId);

    result.fold((failure) => state = state.copyWith(error: failure), (_) async {
      // 팔로우 성공 후 채널 정보 다시 로드
      if (state.channelInfo != null) {
        await loadChannelInfo(memberId);
      }
    });
  }

  /// 회원 언팔로우
  Future<void> unfollowMember(String followId, String memberId) async {
    final result = await unfollowMemberUseCase.execute(followId);

    result.fold((failure) => state = state.copyWith(error: failure), (_) async {
      // 언팔로우 성공 후 채널 정보 다시 로드
      if (state.channelInfo != null) {
        await loadChannelInfo(memberId);
      }
    });
  }

  /// 아티스트 앨범 목록 로딩
  Future<void> loadArtistAlbums(String memberId) async {
    state = state.copyWith(artistAlbumsStatus: MyChannelStatus.loading);

    final result = await getArtistAlbumsUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            artistAlbumsStatus: MyChannelStatus.error,
            error: failure,
          ),
      (albums) =>
          state = state.copyWith(
            artistAlbumsStatus: MyChannelStatus.success,
            artistAlbums: albums,
          ),
    );
  }

  /// 아티스트 공지사항 로딩
  Future<void> loadArtistNotices(String memberId) async {
    state = state.copyWith(artistNoticesStatus: MyChannelStatus.loading);

    final result = await getArtistNoticesUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            artistNoticesStatus: MyChannelStatus.error,
            error: failure,
          ),
      (notices) =>
          state = state.copyWith(
            artistNoticesStatus: MyChannelStatus.success,
            artistNotices: notices,
          ),
    );
  }

  /// 팬톡 목록 로딩
  Future<void> loadFanTalks(String fantalkChannelId) async {
    state = state.copyWith(fanTalksStatus: MyChannelStatus.loading);

    final result = await getFanTalksUseCase.execute(fantalkChannelId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            fanTalksStatus: MyChannelStatus.error,
            error: failure,
          ),
      (fanTalks) =>
          state = state.copyWith(
            fanTalksStatus: MyChannelStatus.success,
            fanTalks: fanTalks,
          ),
    );
  }

  /// 공개된 플레이리스트 로딩
  Future<void> loadPublicPlaylists(String memberId) async {
    state = state.copyWith(publicPlaylistsStatus: MyChannelStatus.loading);

    final result = await getPublicPlaylistsUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            publicPlaylistsStatus: MyChannelStatus.error,
            error: failure,
          ),
      (playlists) =>
          state = state.copyWith(
            publicPlaylistsStatus: MyChannelStatus.success,
            publicPlaylists: playlists,
          ),
    );
  }

  /// 팔로워 목록 로딩
  Future<void> loadFollowers(String memberId) async {
    state = state.copyWith(followersStatus: MyChannelStatus.loading);

    final result = await getFollowersUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            followersStatus: MyChannelStatus.error,
            error: failure,
          ),
      (followers) =>
          state = state.copyWith(
            followersStatus: MyChannelStatus.success,
            followers: followers,
          ),
    );
  }

  /// 팔로잉 목록 로딩
  Future<void> loadFollowings(String memberId) async {
    state = state.copyWith(followingsStatus: MyChannelStatus.loading);

    final result = await getFollowingsUseCase.execute(memberId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            followingsStatus: MyChannelStatus.error,
            error: failure,
          ),
      (followings) =>
          state = state.copyWith(
            followingsStatus: MyChannelStatus.success,
            followings: followings,
          ),
    );
  }

  /// 나의 채널 전체 데이터 로딩
  Future<void> loadMyChannelData(
    String memberId,
    String? fantalkChannelId,
  ) async {
    await loadChannelInfo(memberId);
    await loadArtistAlbums(memberId);
    await loadArtistNotices(memberId);
    if (fantalkChannelId != null) {
      await loadFanTalks(fantalkChannelId);
    }
    await loadPublicPlaylists(memberId);
    await loadFollowers(memberId);
    await loadFollowings(memberId);
  }

  ///////// 공지사항 관련 /////////
  /// 공지사항 상세 정보 조회
  Future<void> loadArtistNoticeDetail(int noticeId) async {
    state = state.copyWith(artistNoticeDetailStatus: MyChannelStatus.loading);

    try {
      final noticeDetail = await getArtistNoticeDetailUseCase(noticeId);
      state = state.copyWith(
        artistNoticeDetailStatus: MyChannelStatus.success,
        artistNoticeDetail: noticeDetail,
      );
    } catch (e) {
      state = state.copyWith(
        artistNoticeDetailStatus: MyChannelStatus.error,
        error: e is Failure ? e : Failure(message: e.toString()),
      );
    }
  }

  /// 새 공지사항 작성
  Future<bool> createArtistNotice(
    String content, {
    MultipartFile? noticeImage,
  }) async {
    state = state.copyWith(createNoticeStatus: MyChannelStatus.loading);

    try {
      await createArtistNoticeUseCase(content, noticeImage: noticeImage);
      state = state.copyWith(createNoticeStatus: MyChannelStatus.success);

      // 공지사항 생성 후 공지사항 목록 새로고침 (현재 로그인한 사용자의 ID 필요)
      // 성공 후 로직 구현은 호출하는 쪽에서 처리

      return true;
    } catch (e) {
      state = state.copyWith(
        createNoticeStatus: MyChannelStatus.error,
        error: e is Failure ? e : Failure(message: e.toString()),
      );
      return false;
    }
  }
}

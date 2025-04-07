import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // MultipartFile 사용
import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/channel_info.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../../data/models/my_channel/public_playlist.dart';
import '../../../data/models/my_channel/neighbor.dart';
import '../../../domain/usecases/my_channel/my_channel_usecases.dart';
import '../../../domain/usecases/my_channel/artist_notice_usecases.dart'
    as notice;

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

/// 나의 채널 뷰모델 provider
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

  /// 회원 팔로우 - 낙관적 UI 업데이트 포함
  Future<bool> followMember(String memberId) async {
    // 현재 채널 정보 저장
    final currentChannelInfo = state.channelInfo;
    if (currentChannelInfo == null) return false;

    try {
      // 1. 낙관적 UI 업데이트 - 즉시 팔로우 상태로 변경
      state = state.copyWith(
        channelInfo: currentChannelInfo.copyWith(isFollowed: true),
      );

      // 2. 실제 API 호출
      final result = await followMemberUseCase.execute(memberId);

      // 3. 결과 처리
      return result.fold(
        (failure) {
          // API 호출 실패 시 원래 상태로 복원
          state = state.copyWith(
            channelInfo: currentChannelInfo,
            error: failure,
          );
          return false;
        },
        (_) async {
          // 성공 시 채널 정보 다시 로드
          await loadChannelInfo(memberId);
          return true;
        },
      );
    } catch (e) {
      // 예외 발생 시 원래 상태로 복원
      state = state.copyWith(
        channelInfo: currentChannelInfo,
        error: e is Failure ? e : Failure(message: e.toString()),
      );
      return false;
    }
  }

  /// 회원 언팔로우 - 낙관적 UI 업데이트 포함
  Future<bool> unfollowMember(String memberId) async {
    // 현재 채널 정보 저장
    final currentChannelInfo = state.channelInfo;
    if (currentChannelInfo == null) return false;

    try {
      // 1. 낙관적 UI 업데이트 - 즉시 언팔로우 상태로 변경
      state = state.copyWith(
        channelInfo: currentChannelInfo.copyWith(isFollowed: false),
      );

      // 2. 실제 API 호출
      final result = await unfollowMemberUseCase.execute(memberId);

      // 3. 결과 처리
      return result.fold(
        (failure) {
          // API 호출 실패 시 원래 상태로 복원
          state = state.copyWith(
            channelInfo: currentChannelInfo,
            error: failure,
          );
          return false;
        },
        (_) async {
          // 성공 시 채널 정보 다시 로드
          await loadChannelInfo(memberId);
          return true;
        },
      );
    } catch (e) {
      // 예외 발생 시 원래 상태로 복원
      state = state.copyWith(
        channelInfo: currentChannelInfo,
        error: e is Failure ? e : Failure(message: e.toString()),
      );
      return false;
    }
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

  /// 모든 섹션을 로딩 상태로 설정
  void setLoadingState() {
    state = state.copyWith(
      channelInfoStatus: MyChannelStatus.loading,
      artistAlbumsStatus: MyChannelStatus.loading,
      artistNoticesStatus: MyChannelStatus.loading,
      fanTalksStatus: MyChannelStatus.loading,
      publicPlaylistsStatus: MyChannelStatus.loading,
      followersStatus: MyChannelStatus.loading,
      followingsStatus: MyChannelStatus.loading,
    );
  }

  /// 나의 채널 전체 데이터 로딩
  Future<void> loadMyChannelData(
    String memberId,
    String? fantalkChannelId,
  ) async {
    // 채널 정보 먼저 로드
    await _loadSafely(() => loadChannelInfo(memberId), '채널 정보');

    // 채널 정보 로드 후 구독자 수 확인
    final channelInfo = state.channelInfo;
    final hasSubscribers =
        channelInfo != null && channelInfo.subscriberCount > 0;

    // 다른 데이터 로드
    _loadSafely(() => loadArtistAlbums(memberId), '아티스트 앨범');
    _loadSafely(() => loadArtistNotices(memberId), '아티스트 공지사항');

    // 구독자가 있는 경우에만 팬톡 로드
    if (hasSubscribers && fantalkChannelId != null) {
      _loadSafely(() => loadFanTalks(fantalkChannelId), '팬톡');
    } else {
      // 구독자가 없는 경우 팬톡 상태를 성공으로 설정하되 데이터는 비움
      state = state.copyWith(
        fanTalksStatus: MyChannelStatus.success,
        fanTalks: null,
      );
    }

    _loadSafely(() => loadPublicPlaylists(memberId), '공개된 플레이리스트');
    _loadSafely(() => loadFollowers(memberId), '팔로워 목록');
    _loadSafely(() => loadFollowings(memberId), '팔로잉 목록');
  }

  // 안전하게 로드하는 헬퍼 메서드
  Future<void> _loadSafely(
    Future<void> Function() loadFunction,
    String dataName,
  ) async {
    try {
      await loadFunction();
    } catch (e) {
      print('$dataName 로드 실패: $e');
      // 에러 상태로 설정하지 않고 무시 (선택적)
    }
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

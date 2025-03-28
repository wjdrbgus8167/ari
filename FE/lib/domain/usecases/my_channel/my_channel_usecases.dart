import 'package:dartz/dartz.dart';
import '../../../core/exceptions/failure.dart';
import '../../../data/models/my_channel/channel_info.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../../data/models/my_channel/public_playlist.dart';
import '../../../data/models/my_channel/neighbor.dart';
import '../../repositories/my_channel/my_channel_repository.dart';

/// 채널 정보 조회 유스케이스
class GetChannelInfoUseCase {
  final MyChannelRepository repository;

  GetChannelInfoUseCase(this.repository);

  Future<Either<Failure, ChannelInfo>> execute(String memberId) {
    return repository.getChannelInfo(memberId);
  }
}

/// 팔로우 유스케이스
class FollowMemberUseCase {
  final MyChannelRepository repository;

  FollowMemberUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(String memberId) {
    return repository.followMember(memberId);
  }
}

/// 언팔로우 유스케이스
class UnfollowMemberUseCase {
  final MyChannelRepository repository;

  UnfollowMemberUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(String followId) {
    return repository.unfollowMember(followId);
  }
}

/// 아티스트 앨범 목록 조회 유스케이스
class GetArtistAlbumsUseCase {
  final MyChannelRepository repository;

  GetArtistAlbumsUseCase(this.repository);

  Future<Either<Failure, List<ArtistAlbum>>> execute(String memberId) {
    return repository.getArtistAlbums(memberId);
  }
}

/// 아티스트 공지사항 조회 유스케이스
class GetArtistNoticesUseCase {
  final MyChannelRepository repository;

  GetArtistNoticesUseCase(this.repository);

  Future<Either<Failure, ArtistNoticeResponse>> execute(String memberId) {
    return repository.getArtistNotices(memberId);
  }
}

/// 아티스트 팬톡 목록 조회 유스케이스
class GetFanTalksUseCase {
  final MyChannelRepository repository;

  GetFanTalksUseCase(this.repository);

  Future<Either<Failure, FanTalkResponse>> execute(String fantalkChannelId) {
    return repository.getFanTalks(fantalkChannelId);
  }
}

/// 공개된 플레이리스트 목록 조회 유스케이스
class GetPublicPlaylistsUseCase {
  final MyChannelRepository repository;

  GetPublicPlaylistsUseCase(this.repository);

  Future<Either<Failure, PublicPlaylistResponse>> execute(String memberId) {
    return repository.getPublicPlaylists(memberId);
  }
}

/// 팔로워 목록 조회 유스케이스
class GetFollowersUseCase {
  final MyChannelRepository repository;

  GetFollowersUseCase(this.repository);

  Future<Either<Failure, FollowerResponse>> execute(String memberId) {
    return repository.getFollowers(memberId);
  }
}

/// 팔로잉 목록 조회 유스케이스
class GetFollowingsUseCase {
  final MyChannelRepository repository;

  GetFollowingsUseCase(this.repository);

  Future<Either<Failure, FollowingResponse>> execute(String memberId) {
    return repository.getFollowings(memberId);
  }
}
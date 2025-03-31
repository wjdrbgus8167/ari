import '../../../data/models/my_channel/channel_info.dart';
import '../../../data/models/my_channel/artist_album.dart';
import '../../../data/models/my_channel/artist_notice.dart';
import '../../../data/models/my_channel/fantalk.dart';
import '../../../data/models/my_channel/public_playlist.dart';
import '../../../data/models/my_channel/neighbor.dart';
import '../../../core/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

/// 나의 채널 관련 리포지토리 인터페이스
abstract class MyChannelRepository {
  /// 채널 정보 조회
  Future<Either<Failure, ChannelInfo>> getChannelInfo(String memberId);
  
  /// 팔로우
  Future<Either<Failure, Unit>> followMember(String memberId);
  
  /// 팔로우 취소
  Future<Either<Failure, Unit>> unfollowMember(String followId);
  
  /// 아티스트의 앨범 목록 조회
  Future<Either<Failure, List<ArtistAlbum>>> getArtistAlbums(String memberId);
  
  /// 아티스트의 공지사항 목록 조회
  Future<Either<Failure, ArtistNoticeResponse>> getArtistNotices(String memberId);
  
  /// 팬톡 목록 조회
  Future<Either<Failure, FanTalkResponse>> getFanTalks(String fantalkChannelId);
  
  /// 공개된 플레이리스트 목록 조회
  Future<Either<Failure, PublicPlaylistResponse>> getPublicPlaylists(String memberId);
  
  /// 팔로워 목록 조회
  Future<Either<Failure, FollowerResponse>> getFollowers(String memberId);
  
  /// 팔로잉 목록 조회
  Future<Either<Failure, FollowingResponse>> getFollowings(String memberId);
}
import '../../data/models/my_channel/channel_info.dart';
import '../../data/models/my_channel/artist_album.dart';
import '../../data/models/my_channel/artist_notice.dart';
import '../../data/models/my_channel/fantalk.dart';
import '../../data/models/my_channel/public_playlist.dart';
import '../../data/models/my_channel/neighbor.dart';
import '../../core/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

/// 마이 채널 관련 리포지토리 인터페이스
///
/// 마이 채널 화면에 필요한 데이터를 관리하는 메서드들을 정의합니다.
/// Either 타입을 사용하여 성공과 실패 케이스를 명확하게 처리합니다.
abstract class MyChannelRepository {
  /// 채널 정보를 조회합니다.
  ///
  /// [memberId] : 조회할 회원의 ID
  /// [return] : 성공 시 채널 정보, 실패 시 Failure 객체
  Future<Either<Failure, ChannelInfo>> getChannelInfo(String memberId);
  
  /// 특정 회원을 팔로우합니다.
  ///
  /// [memberId] : 팔로우할 회원의 ID
  /// [return] : 성공 시 unit, 실패 시 Failure 객체
  Future<Either<Failure, Unit>> followMember(String memberId);
  
  /// 특정 회원 팔로우를 취소합니다.
  ///
  /// [followId] : 취소할 팔로우 관계의 ID
  /// [return] : 성공 시 unit, 실패 시 Failure 객체
  Future<Either<Failure, Unit>> unfollowMember(String followId);
  
  /// 아티스트의 앨범 목록을 조회합니다.
  ///
  /// [memberId] : 조회할 아티스트 회원의 ID
  /// [return] : 성공 시 앨범 목록, 실패 시 Failure 객체
  Future<Either<Failure, List<ArtistAlbum>>> getArtistAlbums(String memberId);
  
  /// 아티스트의 공지사항 목록을 조회합니다.
  ///
  /// [memberId] : 조회할 아티스트 회원의 ID
  /// [return] : 성공 시 공지사항 목록 및 개수 정보, 실패 시 Failure 객체
  Future<Either<Failure, ArtistNoticeResponse>> getArtistNotices(String memberId);
  
  /// 팬톡 목록을 조회합니다.
  ///
  /// [fantalkChannelId] : 조회할 팬톡 채널 ID
  /// [return] : 성공 시 팬톡 목록 및 개수 정보, 실패 시 Failure 객체
  Future<Either<Failure, FanTalkResponse>> getFanTalks(String fantalkChannelId);
  
  /// 공개된 플레이리스트 목록을 조회합니다.
  ///
  /// [memberId] : 조회할 회원의 ID
  /// [return] : 성공 시 공개된 플레이리스트 목록, 실패 시 Failure 객체
  Future<Either<Failure, PublicPlaylistResponse>> getPublicPlaylists(String memberId);
  
  /// 팔로워 목록을 조회합니다.
  ///
  /// [memberId] : 조회할 회원의 ID
  /// [return] : 성공 시 팔로워 목록 및 개수 정보, 실패 시 Failure 객체
  Future<Either<Failure, FollowerResponse>> getFollowers(String memberId);
  
  /// 팔로잉 목록을 조회합니다.
  ///
  /// [memberId] : 조회할 회원의 ID
  /// [return] : 성공 시 팔로잉 목록 및 개수 정보, 실패 시 Failure 객체
  Future<Either<Failure, FollowingResponse>> getFollowings(String memberId);
}
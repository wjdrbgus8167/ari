import 'package:flutter/foundation.dart';
import '../../models/my_channel/channel_info.dart';
import '../../models/my_channel/artist_album.dart';
import '../../models/my_channel/artist_notice.dart';
import '../../models/my_channel/fantalk.dart';
import '../../models/my_channel/public_playlist.dart';
import '../../models/my_channel/neighbor.dart';

abstract class MyChannelRemoteDataSource {
  /// 채널 정보 조회
  /// [memberId] : 조회할 회원의 ID
  /// [return] : 채널 정보 객체 (Future로 비동기 처리)
  Future<ChannelInfo> getChannelInfo(String memberId);

  /// 팔로우
  /// [memberId] : 팔로우할 회원 ID
  /// [return] : 성공 여부
  Future<void> followMember(String memberId);

  /// 팔로우 취소
  /// [followId] : 취소할 팔로우 관계의 ID
  /// [return] : 성공 여부
  Future<void> unfollowMember(String followId);

  /// 아티스트 앨범 목록 조회
  /// [memberId] : 조회할 아티스트 회원 ID
  /// [return] : 앨범 목록 (Future로 비동기 처리)
  Future<List<ArtistAlbum>> getArtistAlbums(String memberId);

  /// 아티스트 공지사항 목록 조회
  /// [memberId] : 조회할 아티스트 회원 ID
  /// [return] : 공지사항 목록 및 개수 (Future로 비동기 처리)
  Future<ArtistNoticeResponse> getArtistNotices(String memberId);

  /// 팬톡 목록 조회
  /// [fantalkChannelId] : 조회할 팬톡 채널 ID
  /// [return] : 팬톡 목록 및 개수 (Future로 비동기 처리)
  Future<FanTalkResponse> getFanTalks(String fantalkChannelId);

  /// 공개된 플레이리스트 목록 조회
  /// [memberId] : 조회할 회원 ID
  /// [return] : 공개된 플레이리스트 목록 (Future로 비동기 처리)
  Future<PublicPlaylistResponse> getPublicPlaylists(String memberId);

  /// 팔로워 목록 조회
  /// [memberId] : 조회할 회원 ID
  /// [return] : 팔로워 목록 및 개수 (Future로 비동기 처리)
  Future<FollowerResponse> getFollowers(String memberId);

  /// 팔로잉 목록 조회
  /// [memberId] : 조회할 회원 ID
  /// [return] : 팔로잉 목록 및 개수 (Future로 비동기 처리)
  Future<FollowingResponse> getFollowings(String memberId);
}

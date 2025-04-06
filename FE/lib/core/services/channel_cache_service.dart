import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/my_channel/channel_info.dart';
import '../../data/models/my_channel/artist_album.dart';
import '../../data/models/my_channel/artist_notice.dart';
import '../../data/models/my_channel/fantalk.dart';
import '../../data/models/my_channel/public_playlist.dart';
import '../../data/models/my_channel/neighbor.dart';

/// 나의 채널 데이터 캐싱 서비스
class ChannelCacheService {
  // 캐시 데이터 저장
  final Map<String, _CachedData<ChannelInfo>> _channelInfoCache = {};
  final Map<String, _CachedData<List<ArtistAlbum>>> _artistAlbumsCache = {};
  final Map<String, _CachedData<ArtistNoticeResponse>> _artistNoticesCache = {};
  final Map<String, _CachedData<FanTalkResponse>> _fanTalksCache = {};
  final Map<String, _CachedData<PublicPlaylistResponse>> _publicPlaylistsCache =
      {};
  final Map<String, _CachedData<FollowerResponse>> _followersCache = {};
  final Map<String, _CachedData<FollowingResponse>> _followingsCache = {};

  // 캐시 만료 시간 (기본 5분)
  final Duration cacheDuration;

  ChannelCacheService({this.cacheDuration = const Duration(minutes: 5)});

  /// 채널 정보 캐시 저장 및 조회
  ChannelInfo? getChannelInfo(String memberId) {
    final cachedData = _channelInfoCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 채널 정보 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cacheChannelInfo(String memberId, ChannelInfo data) {
    _channelInfoCache[memberId] = _CachedData<ChannelInfo>(data, cacheDuration);
    debugPrint('💾 채널 정보 캐시 저장: $memberId');
  }

  /// 아티스트 앨범 캐시 저장 및 조회
  List<ArtistAlbum>? getArtistAlbums(String memberId) {
    final cachedData = _artistAlbumsCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 아티스트 앨범 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cacheArtistAlbums(String memberId, List<ArtistAlbum> data) {
    _artistAlbumsCache[memberId] = _CachedData<List<ArtistAlbum>>(
      data,
      cacheDuration,
    );
    debugPrint('💾 아티스트 앨범 캐시 저장: $memberId');
  }

  /// 아티스트 공지사항 캐시 저장 및 조회
  ArtistNoticeResponse? getArtistNotices(String memberId) {
    final cachedData = _artistNoticesCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 아티스트 공지사항 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cacheArtistNotices(String memberId, ArtistNoticeResponse data) {
    _artistNoticesCache[memberId] = _CachedData<ArtistNoticeResponse>(
      data,
      cacheDuration,
    );
    debugPrint('💾 아티스트 공지사항 캐시 저장: $memberId');
  }

  /// 팬톡 캐시 저장 및 조회
  FanTalkResponse? getFanTalks(String fantalkChannelId) {
    final cachedData = _fanTalksCache[fantalkChannelId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 팬톡 캐시 사용: $fantalkChannelId');
      return cachedData.data;
    }
    return null;
  }

  void cacheFanTalks(String fantalkChannelId, FanTalkResponse data) {
    _fanTalksCache[fantalkChannelId] = _CachedData<FanTalkResponse>(
      data,
      cacheDuration,
    );
    debugPrint('💾 팬톡 캐시 저장: $fantalkChannelId');
  }

  /// 공개된 플레이리스트 캐시 저장 및 조회
  PublicPlaylistResponse? getPublicPlaylists(String memberId) {
    final cachedData = _publicPlaylistsCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 공개 플레이리스트 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cachePublicPlaylists(String memberId, PublicPlaylistResponse data) {
    _publicPlaylistsCache[memberId] = _CachedData<PublicPlaylistResponse>(
      data,
      cacheDuration,
    );
    debugPrint('💾 공개 플레이리스트 캐시 저장: $memberId');
  }

  /// 팔로워 캐시 저장 및 조회
  FollowerResponse? getFollowers(String memberId) {
    final cachedData = _followersCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 팔로워 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cacheFollowers(String memberId, FollowerResponse data) {
    _followersCache[memberId] = _CachedData<FollowerResponse>(
      data,
      cacheDuration,
    );
    debugPrint('💾 팔로워 캐시 저장: $memberId');
  }

  /// 팔로잉 캐시 저장 및 조회
  FollowingResponse? getFollowings(String memberId) {
    final cachedData = _followingsCache[memberId];
    if (cachedData != null && !cachedData.isExpired()) {
      debugPrint('💾 팔로잉 캐시 사용: $memberId');
      return cachedData.data;
    }
    return null;
  }

  void cacheFollowings(String memberId, FollowingResponse data) {
    _followingsCache[memberId] = _CachedData<FollowingResponse>(
      data,
      cacheDuration,
    );
    debugPrint('💾 팔로잉 캐시 저장: $memberId');
  }

  /// 특정 멤버 ID의 모든 캐시 삭제 (데이터 갱신 필요 시)
  void invalidateCache(String memberId) {
    _channelInfoCache.remove(memberId);
    _artistAlbumsCache.remove(memberId);
    _artistNoticesCache.remove(memberId);
    _publicPlaylistsCache.remove(memberId);
    _followersCache.remove(memberId);
    _followingsCache.remove(memberId);
    debugPrint('💾 캐시 무효화: $memberId');
  }

  /// 로그 목적의 캐시 현황 문자열 생성
  String getCacheStatus() {
    final now = DateFormat('HH:mm:ss').format(DateTime.now());
    return '[캐시 상태 $now]\n'
        '채널 정보: ${_channelInfoCache.length}개\n'
        '아티스트 앨범: ${_artistAlbumsCache.length}개\n'
        '공지사항: ${_artistNoticesCache.length}개\n'
        '팬톡: ${_fanTalksCache.length}개\n'
        '플레이리스트: ${_publicPlaylistsCache.length}개\n'
        '팔로워: ${_followersCache.length}개\n'
        '팔로잉: ${_followingsCache.length}개';
  }
}

/// 캐시된 데이터 래퍼 클래스
class _CachedData<T> {
  final T data;
  final DateTime expiryTime;

  _CachedData(this.data, Duration cacheDuration)
    : expiryTime = DateTime.now().add(cacheDuration);

  bool isExpired() {
    return DateTime.now().isAfter(expiryTime);
  }
}

/// 검색 API 응답 모델
/// 아티스트 및 트랙 검색 결과
class SearchResponse {
  final List<ArtistSearchResult> artists;
  final List<TrackSearchResult> tracks;

  SearchResponse({required this.artists, required this.tracks});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    // null 안전성 처리: artists나 tracks가 null인 경우 빈 리스트 반환
    return SearchResponse(
      artists:
          json['artists'] != null
              ? List<ArtistSearchResult>.from(
                (json['artists'] as List).map(
                  (artist) => ArtistSearchResult.fromJson(artist),
                ),
              )
              : [],
      tracks:
          json['tracks'] != null
              ? List<TrackSearchResult>.from(
                (json['tracks'] as List).map(
                  (track) => TrackSearchResult.fromJson(track),
                ),
              )
              : [],
    );
  }
}

/// 아티스트 검색 결과
class ArtistSearchResult {
  final int memberId;
  final String nickname;
  final String profileImageUrl;

  ArtistSearchResult({
    required this.memberId,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory ArtistSearchResult.fromJson(Map<String, dynamic> json) {
    // null 처리
    return ArtistSearchResult(
      memberId: json['memberId'] ?? 0,
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

/// 트랙 검색 결과
class TrackSearchResult {
  final int trackId;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;

  TrackSearchResult({
    required this.trackId,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  });

  factory TrackSearchResult.fromJson(Map<String, dynamic> json) {
    // null 처리
    return TrackSearchResult(
      trackId: json['trackId'] ?? 0,
      trackTitle: json['trackTitle'] ?? '',
      artist: json['artist'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
    );
  }
}

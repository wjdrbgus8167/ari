/// 검색 API 응답 모델
/// 아티스트 및 트랙 검색 결과
class SearchResponse {
  final List<ArtistSearchResult> artists;
  final List<TrackSearchResult> tracks;

  SearchResponse({required this.artists, required this.tracks});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      artists:
          (json['artists'] as List)
              .map((artist) => ArtistSearchResult.fromJson(artist))
              .toList(),
      tracks:
          (json['tracks'] as List)
              .map((track) => TrackSearchResult.fromJson(track))
              .toList(),
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
    return ArtistSearchResult(
      memberId: json['memberId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
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
    return TrackSearchResult(
      trackId: json['trackId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
    );
  }
}

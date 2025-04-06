/// 공개된 플레이리스트 모델 클래스
class PublicPlaylist {
  final int playlistId;
  final String playlistTitle;
  final bool publicYn; // 공개 여부
  final int trackCount; // 트랙 수
  final String? artist; // 아티스트 이름
  final String? coverImageUrl; // 커버 URL

  /// 생성자(객체 초기화)
  PublicPlaylist({
    required this.playlistId,
    required this.playlistTitle,
    required this.publicYn,
    required this.trackCount,
    this.artist,
    this.coverImageUrl,
  });

  /// [return] 변환된 PublicPlaylist 객체
  factory PublicPlaylist.fromJson(Map<String, dynamic> json) {
    return PublicPlaylist(
      playlistId: json['playlistId'] ?? 0,
      playlistTitle: json['playlistTitle'] ?? '',
      publicYn: json['publicYn'] ?? false,
      trackCount: json['trackCount'] ?? 0,
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
    );
  }

  /// [return] 변환된 JSON 맵
  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'playlistTitle': playlistTitle,
      'publicYn': publicYn,
      'trackCount': trackCount,
      'artist': artist,
      'coverImageUrl': coverImageUrl,
    };
  }
}

/// API로부터 받은 플레이리스트 목록 데이터 저장
class PublicPlaylistResponse {
  final List<PublicPlaylist> playlists; // 공개된 플레이리스트 목록

  PublicPlaylistResponse({required this.playlists});

  /// [return] 변환된 PublicPlaylistResponse 객체
  factory PublicPlaylistResponse.fromJson(Map<String, dynamic> json) {
    final playlistsList = json['playlists'] as List<dynamic>? ?? [];

    return PublicPlaylistResponse(
      playlists:
          playlistsList
              .map((playlistJson) => PublicPlaylist.fromJson(playlistJson))
              .toList(),
    );
  }
}

/// 공개된 플레이리스트 모델 클래스
class PublicPlaylist {
  final int playlistId;
  final String playlistTitle;
  final String playlistImageUrl;
  final int shareCount; // 플레이리스트 공유 횟수

  /// 생성자(객체 초기화)
  PublicPlaylist({
    required this.playlistId,
    required this.playlistTitle,
    required this.playlistImageUrl,
    required this.shareCount,
  });

  /// [return] 변환된 PublicPlaylist 객체
  factory PublicPlaylist.fromJson(Map<String, dynamic> json) {
    return PublicPlaylist(
      playlistId: json['playlistId'] ?? 0,
      playlistTitle: json['playlistTitle'] ?? '',
      playlistImageUrl: json['playlistImageUrl'] ?? '',
      shareCount: json['shareCount'] ?? 0,
    );
  }
  /// [return] 변환된 JSON 맵
  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'playlistTitle': playlistTitle,
      'playlistImageUrl': playlistImageUrl,
      'shareCount': shareCount,
    };
  }
}

/// API로부터 받은 플레이리스트 목록 데이터 저장
class PublicPlaylistResponse {
  final List<PublicPlaylist> playlists; // 공개된 플레이리스트 목록
  PublicPlaylistResponse({
    required this.playlists,
  });

  /// JSON의 'playlists' 배열의 각 항목을 PublicPlaylist 객체로 변환
  /// [return] 변환된 PublicPlaylistResponse 객체
  factory PublicPlaylistResponse.fromJson(Map<String, dynamic> json) {
    final playlistsList = json['playlists'] as List<dynamic>? ?? [];
    
    return PublicPlaylistResponse(
      playlists: playlistsList
          .map((playlistJson) => PublicPlaylist.fromJson(playlistJson))
          .toList(),
    );
  }
}
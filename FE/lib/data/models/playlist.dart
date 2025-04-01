// lib/data/models/playlist.dart
class Playlist {
  final int playlistId;
  final int shareCount;
  final bool publicYn;
  final String playlistTitle;

  Playlist({
    required this.playlistId,
    required this.shareCount,
    required this.publicYn,
    required this.playlistTitle,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      // API 응답에서는 'playlistId' 키를 사용합니다.
      playlistId: json['playlistId'] as int,
      // API 응답에 memberId가 없다면 기본값 0을 사용
      // API 응답의 trackCount를 shareCount로 사용 (또는 별도의 매핑이 필요하다면 수정)
      shareCount: json['trackCount'] != null ? json['trackCount'] as int : 0,
      // API 응답에 publicYn 필드가 없다면 기본값 false 사용
      publicYn: json['publicYn'] is bool ? json['publicYn'] as bool : false,
      // API 응답에서는 'playlistTitle' 키를 사용합니다.
      playlistTitle: json['playlistTitle'] as String,

      // deletedAt 및 createdAt은 응답에 없으므로 기본값 또는 현재 시간을 할당
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlistId': playlistId,
      'trackCount': shareCount,
      'publicYn': publicYn,
      'playlistTitle': playlistTitle,
    };
  }
}

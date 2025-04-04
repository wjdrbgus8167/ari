/// API에서 받아온 앨범 정보 -> ArtistAlbum
class ArtistAlbum {
  final int albumId;
  final String albumTitle;
  final String artist;
  final String coverImageUrl;
  final int trackCount;
  final String description;
  final String releasedAt;
  final String genre;
  final int memberId;

  ArtistAlbum({
    required this.albumId,
    required this.albumTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.trackCount,
    this.description = '',
    this.releasedAt = '',
    this.genre = '',
    this.memberId = 0,
  });

  /// [json] API에서 받아온 JSON 맵
  /// [return] ArtistAlbum
  factory ArtistAlbum.fromJson(Map<String, dynamic> json) {
    return ArtistAlbum(
      albumId: json['albumId'] ?? 0,
      albumTitle: json['albumTitle'] ?? '',
      artist: json['artist'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      trackCount: json['trackCount'] ?? 0,
      description: json['description'] ?? '',
      releasedAt: json['releasedAt'] ?? '',
      genre: json['genre'] ?? '',
      memberId: json['memberId'] ?? 0,
    );
  }

  /// ArtistAlbum -> JSON 맵으로 변환하는 메서드
  /// [return] 변환된 JSON 맵
  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'albumTitle': albumTitle,
      'artist': artist,
      'coverImageUrl': coverImageUrl,
      'trackCount': trackCount,
      'description': description,
      'releasedAt': releasedAt,
      'genre': genre,
      'memberId': memberId,
    };
  }
}

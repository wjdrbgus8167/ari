class PlaylistTrackItem {
  final int trackOrder;
  final int trackId;
  final String composer;
  final String artist;
  final String coverImageUrl;
  final String lyricist;
  final String lyrics;
  final String trackFileUrl;
  final int trackLikeCount;
  final int trackNumber;
  final String trackTitle;
  final int albumId;
  final int artistId;

  PlaylistTrackItem({
    required this.trackOrder,
    required this.trackId,
    required this.artist,
    required this.coverImageUrl,
    required this.composer,
    required this.lyricist,
    required this.lyrics,
    required this.trackFileUrl,
    required this.trackLikeCount,
    required this.trackNumber,
    required this.trackTitle,
    required this.albumId,
    this.artistId = 0,
  });

  factory PlaylistTrackItem.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackItem(
      trackOrder: json['trackOrder'] as int? ?? 0,
      trackId: json['trackId'] as int? ?? 0,
      artist: json['artist'] as String? ?? '', // ✅ 수정!
      coverImageUrl: json['coverImageUrl'] as String? ?? '', // ✅ 수정!

      composer: json['composer'] as String? ?? '',
      lyricist: json['lyricist'] as String? ?? '',
      lyrics: json['lyrics'] as String? ?? '',
      trackFileUrl: json['trackFileUrl'] ?? '',
      trackLikeCount: json['trackLikeCount'] as int? ?? 0,
      trackNumber: json['trackNumber'] as int? ?? 0,
      trackTitle: json['trackTitle'] as String? ?? '',
      albumId: json['albumId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackOrder': trackOrder,
      'trackId': trackId,
      'artist': artist,
      'coverImageUrl': coverImageUrl,
      'composer': composer,
      'lyricist': lyricist,
      'lyrics': lyrics,
      'trackFileUrl': trackFileUrl,
      'trackLikeCount': trackLikeCount,
      'trackNumber': trackNumber,
      'trackTitle': trackTitle,
      'albumId': albumId,
    };
  }
}

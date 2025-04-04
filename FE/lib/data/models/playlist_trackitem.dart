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
  });

  factory PlaylistTrackItem.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackItem(
      trackOrder: json['trackOrder'] as int,
      trackId: json['trackId'] as int,
      artist: json['artist'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      composer: json['composer'] as String,
      lyricist: json['lyricist'] as String,
      lyrics: json['lyrics'] as String,
      trackFileUrl: json['trackFileUrl'] as String,
      trackLikeCount: json['trackLikeCount'] as int,
      trackNumber: json['trackNumber'] as int,
      trackTitle: json['trackTitle'] as String,
      albumId: json['albumId'] as int,
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

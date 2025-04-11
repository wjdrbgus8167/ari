class LikeyTracksResponse {
  final List<LikeyTrack> tracks;
  final int trackCount;

  LikeyTracksResponse({required this.tracks, required this.trackCount});

  factory LikeyTracksResponse.fromJson(Map<String, dynamic> json) {
    return LikeyTracksResponse(
      tracks:
          (json['tracks'] as List)
              .map((track) => LikeyTrack.fromJson(track))
              .toList(),
      trackCount: json['trackCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'trackCount': trackCount,
    };
  }
}

class LikeyTrack {
  final int trackId;
  final int albumId;
  final String trackTitle;
  final String artist;
  final String coverImageUrl;

  LikeyTrack({
    required this.trackId,
    required this.albumId,
    required this.trackTitle,
    required this.artist,
    required this.coverImageUrl,
  });

  factory LikeyTrack.fromJson(Map<String, dynamic> json) {
    return LikeyTrack(
      trackId: json['trackId'],
      albumId: json['albumId'],
      trackTitle: json['trackTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'albumId': albumId,
      'trackTitle': trackTitle,
      'artist': artist,
      'coverImageUrl': coverImageUrl,
    };
  }
}

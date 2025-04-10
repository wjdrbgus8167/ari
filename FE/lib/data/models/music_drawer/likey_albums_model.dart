class LikeyAlbumsResponse {
  final List<LikeyAlbum> albums;
  final int albumCount;

  LikeyAlbumsResponse({
    required this.albums,
    required this.albumCount,
  });

  factory LikeyAlbumsResponse.fromJson(Map<String, dynamic> json) {
    return LikeyAlbumsResponse(
      albums: (json['albums'] as List)
          .map((album) => LikeyAlbum.fromJson(album))
          .toList(),
      albumCount: json['albumCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albums': albums.map((album) => album.toJson()).toList(),
      'albumCount': albumCount,
    };
  }
}

class LikeyAlbum {
  final int albumId;
  final String albumTitle;
  final String artist;
  final String coverImageUrl;
  final int trackCount;

  LikeyAlbum({
    required this.albumId,
    required this.albumTitle,
    required this.artist,
    required this.coverImageUrl,
    required this.trackCount,
  });

  factory LikeyAlbum.fromJson(Map<String, dynamic> json) {
    return LikeyAlbum(
      albumId: json['albumId'],
      albumTitle: json['albumTitle'],
      artist: json['artist'],
      coverImageUrl: json['coverImageUrl'],
      trackCount: json['trackCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'albumTitle': albumTitle,
      'artist': artist,
      'coverImageUrl': coverImageUrl,
      'trackCount': trackCount,
    };
  }
}
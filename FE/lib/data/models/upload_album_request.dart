class UploadAlbumRequest {
  final String genreName;
  final String albumTitle;
  final String discription;
  final String coverImage;
  final List<TrackUploadRequest> tracks;

  UploadAlbumRequest({
    required this.genreName,
    required this.albumTitle,
    required this.discription,
    required this.coverImage,
    required this.tracks,
  });

  Map<String, dynamic> toJson() {
    return {
      'genreName': genreName,
      'albumTitle': albumTitle,
      'discription': discription,
      'coverImage': coverImage,
      'Tracks': tracks.map((track) => track.toJson()).toList(),
    };
  }
}

class TrackUploadRequest {
  final int trackNumber;
  final String trackTitle;
  final String composer;
  final String lyricist;
  final String lyrics;
  final String fileName;

  TrackUploadRequest({
    required this.trackNumber,
    required this.trackTitle,
    required this.composer,
    required this.lyricist,
    required this.lyrics,
    required this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'trackNumber': trackNumber,
      'trackTitle': trackTitle,
      'composer': composer,
      'lyricist': lyricist,
      'lyrics': lyrics,
      'fileName': fileName,
    };
  }
}
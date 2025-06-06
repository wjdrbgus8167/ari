// lib/domain/entities/playlist_trackitem.dart
import 'package:ari/data/models/track.dart' as data;

class PlaylistTrackItem {
  final int trackOrder;
  final int trackId;
  final String composer;
  final String artist;
  final int artistId;
  final String coverImageUrl;
  final String lyricist;
  final String lyrics;
  final String trackFileUrl;
  final int trackLikeCount;
  final int trackNumber;
  final String trackTitle;
  final int albumId;

  const PlaylistTrackItem({
    required this.trackOrder,
    required this.trackId,
    required this.artist,
    required this.artistId,
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
      composer: json['composer'] as String,
      artist: json['artistName'] as String? ?? '',
      artistId:
          json['artistId'] is int
              ? json['artistId']
              : int.tryParse(json['artistId']?.toString() ?? '') ?? 0,
      coverImageUrl: json['trackCoverImageUrl'] as String? ?? '',
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

  // data.Track으로 변환하는 메서드 추가
  data.Track toDataTrack() {
    return data.Track(
      artistId: artistId,
      id: trackId,
      trackTitle: trackTitle,
      artist: artist,
      composer: composer,
      lyricist: lyricist,
      albumId: albumId,
      trackFileUrl: trackFileUrl,
      lyrics: lyrics,
      coverUrl: coverImageUrl,
      trackLikeCount: trackLikeCount,
      // 필요한 경우 나머지 필드 추가
    );
  }
}

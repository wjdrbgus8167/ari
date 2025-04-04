import 'package:ari/data/models/playlist_trackitem.dart';

class Playlist {
  final int id; // API의 playlistId 값을 매핑
  final int trackCount; // API의 trackCount 값
  final int shareCount; // API의 shareCount 값
  final bool isPublic; // API의 publicYn 값을 매핑
  final String title; // API의 playlistTitle 값을 매핑
  final String coverImageUrl; // API의 coverImageUrl 값을 매핑
  final List<PlaylistTrackItem> tracks;

  Playlist({
    required this.id,
    required this.trackCount,
    required this.shareCount,
    required this.isPublic,
    required this.title,
    required this.coverImageUrl,

    this.tracks = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['playlistId'] as int,
      trackCount: json['trackCount'] != null ? json['trackCount'] as int : 0,
      shareCount: json['shareCount'] != null ? json['shareCount'] as int : 0,
      isPublic: json['publicYn'] is bool ? json['publicYn'] as bool : false,
      title: json['playlistTitle'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      tracks:
          json['tracks'] != null
              ? (json['tracks'] as List)
                  .map((e) => PlaylistTrackItem.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlistId': id,
      'trackCount': trackCount,
      'shareCount': shareCount,
      'publicYn': isPublic,
      'playlistTitle': title,
      'tracks': tracks.map((e) => e.toJson()).toList(),
    };
  }
}

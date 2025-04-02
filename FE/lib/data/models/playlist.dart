import 'package:ari/data/models/playlist_trackitem.dart';

class Playlist {
  final int playlistId;
  final int trackCount;
  final int shareCount;
  final bool publicYn;
  final String playlistTitle;
  final List<PlaylistTrackItem> tracks;

  Playlist({
    required this.playlistId,
    required this.trackCount,
    required this.shareCount,
    required this.publicYn,
    required this.playlistTitle,
    this.tracks = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlistId'] as int,
      trackCount: json['trackCount'] != null ? json['trackCount'] as int : 0,
      shareCount: json['shareCount'] != null ? json['shareCount'] as int : 0,
      publicYn: json['publicYn'] is bool ? json['publicYn'] as bool : false,
      playlistTitle: json['playlistTitle'] as String,
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
      'playlistId': playlistId,
      'trackCount': trackCount,
      'shareCount': shareCount,
      'publicYn': publicYn,
      'playlistTitle': playlistTitle,
      'tracks': tracks.map((e) => e.toJson()).toList(),
    };
  }
}

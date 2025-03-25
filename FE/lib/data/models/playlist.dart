// lib/data/models/playlist.dart

import 'package:ari/data/models/playlist_trackitem.dart';
import 'package:ari/data/models/track.dart';

class Playlist {
  final int playlistId;
  final String playlistTitle;
  final bool publicYn;
  final List<PlaylistTrackItem> tracks;

  Playlist({
    required this.playlistId,
    required this.playlistTitle,
    required this.publicYn,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final List<dynamic> tracksJson = json['tracks'] ?? [];

    final tracksList =
        tracksJson.map((json) {
          final track = Track(
            id: json['id'],
            trackTitle: json['track_title'],
            artist: json['artist'],
            composer: json['composer'] ?? '',
            lyricist: json['lyricist'] ?? '',
            albumId: json['album_id']?.toString() ?? '0',
            trackFileUrl: json['track_file_url'] ?? '',
            lyrics: json['lyrics'] ?? '',
            coverUrl: json['cover_url'],
          );

          final int trackOrder = json['playlist_tracks']?['track_order'] ?? 0;

          return PlaylistTrackItem(track: track, trackOrder: trackOrder);
        }).toList();

    return Playlist(
      playlistId: json['playlistId'],
      playlistTitle: json['playlistTitle'],
      publicYn: json['public_yn'] == 'Y' || json['public_yn'] == true,
      tracks: tracksList,
    );
  }
}

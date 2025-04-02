import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'package:ari/domain/entities/track.dart';

class Playlist {
  final int playlistId;
  final String playlistTitle;
  final bool publicYn;
  final int shareCount;
  final List<PlaylistTrackItem> tracks;

  Playlist({
    required this.playlistId,
    required this.playlistTitle,
    required this.publicYn,
    required this.shareCount,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final List<dynamic> tracksJson = json['tracks'] ?? [];

    final tracksList =
        tracksJson.map((json) {
          final track = Track(
            albumId: int.tryParse(json['album_id']?.toString() ?? '0') ?? 0,
            trackId: json['id'],
            trackTitle: json['track_title'],
            artistName: json['artist'],
            composer: json['composer'] ?? '',
            lyricist: json['lyricist'] ?? '',
            trackFileUrl: json['track_file_url'] ?? '',
            lyric: json['lyrics'] ?? '',
            coverUrl: json['cover_url'],
            trackNumber: json['track_number'] ?? 0,
            commentCount: json['comment_count'] ?? 0,
            createdAt: json['created_at'] ?? '',
            trackLikeCount: json['track_like_count'] ?? 0,
            comments: [], // 댓글은 포함하지 않음
          );

          final int trackOrder = json['playlist_tracks']?['track_order'] ?? 0;

          return PlaylistTrackItem(track: track, trackOrder: trackOrder);
        }).toList();

    return Playlist(
      playlistId: json['playlistId'],
      playlistTitle: json['playlistTitle'],
      publicYn: json['public_yn'] == 'Y' || json['public_yn'] == true,
      shareCount: json['share_count'],
      tracks: tracksList,
    );
  }
}

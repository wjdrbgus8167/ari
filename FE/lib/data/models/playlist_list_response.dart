import 'package:ari/domain/entities/playlist.dart';

class PlaylistListResponse {
  final List<Playlist> playlists;

  PlaylistListResponse({required this.playlists});

  factory PlaylistListResponse.fromJson(Map<String, dynamic> json) {
    final playlistsJson = (json['data']?['playlists'] as List<dynamic>?) ?? [];
    final playlists =
        playlistsJson
            .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
            .toList();
    return PlaylistListResponse(playlists: playlists);
  }
}

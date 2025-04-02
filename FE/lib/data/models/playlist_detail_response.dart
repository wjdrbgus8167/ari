import 'package:ari/domain/entities/playlist_trackitem.dart';

class PlaylistDetailResponse {
  final List<PlaylistTrackItem> tracks;

  PlaylistDetailResponse({required this.tracks});

  factory PlaylistDetailResponse.fromJson(Map<String, dynamic> json) {
    final tracksJson = (json['data']?['tracks'] as List<dynamic>?) ?? [];
    final tracks =
        tracksJson
            .map((e) => PlaylistTrackItem.fromJson(e as Map<String, dynamic>))
            .toList();
    return PlaylistDetailResponse(tracks: tracks);
  }
}

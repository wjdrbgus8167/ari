class Playlist {
  final int playlistId;
  final String playlistTitle;
  final bool publicYn;
  final List<PlaylistTrack> tracks;

  Playlist({
    required this.playlistId,
    required this.playlistTitle,
    required this.publicYn,
    required this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final List<dynamic> tracksJson = json['tracks'] ?? [];
    final tracksList =
        tracksJson
            .map((trackJson) => PlaylistTrack.fromJson(trackJson))
            .toList();
    return Playlist(
      playlistId:
          json['playlistId'] is int
              ? json['playlistId']
              : int.parse(json['playlistId'].toString()),
      playlistTitle: json['playlistTitle'],
      publicYn: json['public_yn'] == 'Y' || json['public_yn'] == true,
      tracks: tracksList,
    );
  }
}

class PlaylistTrack {
  final String trackTitle;
  final int trackOrder;
  final String nickname;

  PlaylistTrack({
    required this.trackTitle,
    required this.trackOrder,
    required this.nickname,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      trackTitle: json['track_title'],
      trackOrder: json['playlist_tracks']?['track_order'] ?? 0,
      nickname: json['members']?['nickname'] ?? '',
    );
  }
}

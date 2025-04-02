import 'package:ari/data/models/playlist.dart' as data;
import 'package:ari/domain/entities/playlist.dart' as domain;
import 'package:ari/domain/entities/playlist_trackitem.dart'; // 추가

domain.Playlist mapDataPlaylistToDomain(data.Playlist dataPlaylist) {
  return domain.Playlist(
    id: dataPlaylist.playlistId,
    title: dataPlaylist.playlistTitle,
    isPublic: dataPlaylist.publicYn,
    shareCount: dataPlaylist.shareCount,
    tracks:
        dataPlaylist.tracks.map((track) {
          return PlaylistTrackItem(
            // 도메인 PlaylistTrackItem 사용
            track: track.track,
            trackOrder: track.trackOrder,
          );
        }).toList(),
  );
}

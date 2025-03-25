import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/playlist_trackitem.dart';
import 'package:ari/data/models/track.dart'; // ✅ 이 줄을 추가

class MockPlaylistData {
  static List<Playlist> getMockPlaylists() {
    return [
      Playlist(
        playlistId: 1,
        playlistTitle: 'Mock Playlist 1',
        publicYn: true,
        tracks: [
          PlaylistTrackItem(
            track: Track(
              id: 1,
              trackTitle: 'song1',
              artist: 'Artist1',
              composer: '',
              lyricist: '',
              albumId: 'album1',
              trackFileUrl: '',
              lyrics: '',
            ),
            trackOrder: 1,
          ),
          PlaylistTrackItem(
            track: Track(
              id: 2,
              trackTitle: 'song2',
              artist: 'Artist2',
              composer: '',
              lyricist: '',
              albumId: 'album1',
              trackFileUrl: '',
              lyrics: '',
            ),
            trackOrder: 2,
          ),
        ],
      ),
      Playlist(
        playlistId: 2,
        playlistTitle: 'Mock Playlist 2',
        publicYn: false,
        tracks: [],
      ),
    ];
  }
}

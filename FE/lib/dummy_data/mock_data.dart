import 'package:ari/data/models/album.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/data/models/playlist_trackitem.dart';
import 'package:ari/data/models/playlist.dart';

class MockData {
  static List<Track> getListeningQueue() {
    return [
      Track(
        id: 1,
        trackTitle: 'Too Bad (feat. Anders)',
        artist: 'G-DRAGON',
        composer: 'G-DRAGON',
        lyricist: 'G-DRAGON',
        albumId: 'album1',
        trackFileUrl: 'https://example.com/song1.mp3',
        lyrics: '가사 내용 1',
        coverUrl: 'https://example.com/cover1.jpg',
      ),
      Track(
        id: 2,
        trackTitle: 'Love Scenario',
        artist: 'iKON',
        composer: 'B.I, Bobby',
        lyricist: 'B.I, Bobby',
        albumId: 'album2',
        trackFileUrl: 'https://example.com/song2.mp3',
        lyrics: '가사 내용 2',
        coverUrl: 'https://example.com/cover2.jpg',
      ),
      Track(
        id: 3,
        trackTitle: 'Dynamite',
        artist: 'BTS',
        composer: 'David Stewart',
        lyricist: 'Jessica Agombar',
        albumId: 'album3',
        trackFileUrl: 'https://example.com/song3.mp3',
        lyrics: '가사 내용 3',
        coverUrl: 'https://example.com/cover3.jpg',
      ),
      Track(
        id: 4,
        trackTitle: 'Hype Boy',
        artist: 'NewJeans',
        composer: '250',
        lyricist: 'Minji, Danielle',
        albumId: 'album4',
        trackFileUrl: 'https://example.com/song4.mp3',
        lyrics: '가사 내용 4',
        coverUrl: 'https://example.com/cover4.jpg',
      ),
      Track(
        id: 5,
        trackTitle: 'LALISA',
        artist: 'LISA',
        composer: 'Teddy Park',
        lyricist: 'Teddy Park, Bekuh Boom',
        albumId: 'album5',
        trackFileUrl: 'https://example.com/song5.mp3',
        lyrics: '가사 내용 5',
        coverUrl: 'https://example.com/cover5.jpg',
      ),
    ];
  }

  static List<Album> getLatestAlbums() {
    return [
      Album(
        id: 1,
        title: 'Pain',
        artist: 'Chris Jones',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_1.jpg',
        releaseDate: DateTime(2025, 1, 10),
      ),
      Album(
        id: 2,
        title: 'Winter Love',
        artist: 'Alice Kim',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_2.jpg',
        releaseDate: DateTime(2025, 2, 14),
      ),
      Album(
        id: 3,
        title: 'Autumn Breeze',
        artist: 'Bob Lee',
        genre: 'hiphop',
        coverUrl: 'https://example.com/album_cover_3.jpg',
        releaseDate: DateTime(2025, 3, 20),
      ),
      Album(
        id: 4,
        title: 'Spring Bloom',
        artist: 'Jane Park',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_4.jpg',
        releaseDate: DateTime(2025, 4, 5),
      ),
      Album(
        id: 5,
        title: 'Night Sky',
        artist: 'Mason Lee',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_5.jpg',
        releaseDate: DateTime(2025, 5, 30),
      ),
      Album(
        id: 6,
        title: 'Sunny Days',
        artist: 'Ellen Kim',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_6.jpg',
        releaseDate: DateTime(2025, 6, 15),
      ),
      Album(
        id: 7,
        title: 'Rainy Mood',
        artist: 'Mark Choi',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_7.jpg',
        releaseDate: DateTime(2025, 7, 22),
      ),
      Album(
        id: 8,
        title: 'Ocean Waves',
        artist: 'Lily Chen',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_8.jpg',
        releaseDate: DateTime(2025, 8, 3),
      ),
      Album(
        id: 9,
        title: 'Mountain High',
        artist: 'Sam Woo',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_9.jpg',
        releaseDate: DateTime(2025, 9, 18),
      ),
      Album(
        id: 10,
        title: 'City Lights',
        artist: 'Nina Park',
        genre: 'band',
        coverUrl: 'https://example.com/album_cover_10.jpg',
        releaseDate: DateTime(2025, 10, 25),
      ),
    ];
  }

  static List<Album> getPopularAlbums() {
    return [
      Album(
        id: 11,
        title: 'Summer Vibes',
        artist: 'DJ Max',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_11.jpg',
        releaseDate: DateTime(2024, 6, 1),
      ),
      Album(
        id: 12,
        title: 'Golden Hits',
        artist: 'Various Artists',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_12.jpg',
        releaseDate: DateTime(2023, 12, 1),
      ),
      Album(
        id: 13,
        title: 'Rhythm Nation',
        artist: 'Beat Crew',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_13.jpg',
        releaseDate: DateTime(2024, 1, 15),
      ),
      Album(
        id: 14,
        title: 'Electric Pulse',
        artist: 'Neon Lights',
        genre: 'band',

        coverUrl: 'https://example.com/album_cover_14.jpg',
        releaseDate: DateTime(2024, 2, 28),
      ),
      Album(
        id: 15,
        title: 'Vintage Vibes',
        artist: 'Retro Beats',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_15.jpg',
        releaseDate: DateTime(2024, 3, 10),
      ),
      Album(
        id: 16,
        title: 'Rock Anthem',
        artist: 'The Strikers',
        genre: 'acoustic',

        coverUrl: 'https://example.com/album_cover_16.jpg',
        releaseDate: DateTime(2024, 4, 20),
      ),
      Album(
        id: 17,
        title: 'Indie Dreams',
        artist: 'Dreamers',
        genre: 'rnb',

        coverUrl: 'https://example.com/album_cover_17.jpg',
        releaseDate: DateTime(2024, 5, 5),
      ),
      Album(
        id: 18,
        title: 'Pop Explosion',
        artist: 'Starburst',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_18.jpg',
        releaseDate: DateTime(2024, 6, 18),
      ),
      Album(
        id: 19,
        title: 'Folk Tales',
        artist: 'The Wanderers',
        genre: 'rnb',

        coverUrl: 'https://example.com/album_cover_19.jpg',
        releaseDate: DateTime(2024, 7, 30),
      ),
      Album(
        id: 20,
        title: 'Smooth Jazz',
        artist: 'Jazz Masters',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_20.jpg',
        releaseDate: DateTime(2024, 8, 12),
      ),
    ];
  }

  static List<Playlist> getPopularPlaylists() {
    return [
      Playlist(
        playlistId: 1,
        playlistTitle: 'Top 50 K-Pop',
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
          PlaylistTrackItem(
            track: Track(
              id: 3,
              trackTitle: 'song2',
              artist: 'Artist2',
              composer: '',
              lyricist: '',
              albumId: 'album1',
              trackFileUrl: '',
              lyrics: '',
            ),
            trackOrder: 3,
          ),
        ],
      ),
      Playlist(
        playlistId: 2,
        playlistTitle: 'Relaxing Jazz',
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
        playlistId: 3,
        playlistTitle: 'Rock Classics',
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
        playlistId: 4,
        playlistTitle: 'Hip Hop Beats',
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
        playlistId: 5,
        playlistTitle: 'Indie Mix',
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
        playlistId: 6,
        playlistTitle: 'Workout Mix',
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
        playlistId: 7,
        playlistTitle: 'Chill Vibes',
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
        playlistId: 8,
        playlistTitle: 'Party Hits',
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
        playlistId: 9,
        playlistTitle: 'Acoustic Sessions',
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
        playlistId: 10,
        playlistTitle: 'Electronic Essentials',
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
    ];
  }

  static List<Track> getHot50Titles() {
    return List.generate(50, (index) {
      int id = index + 1;
      return Track(
        id: id,
        composer: 'Composer $id',
        lyricist: 'Lyricist $id',
        lyrics: 'Lyrics for track $id',
        trackTitle: 'Track Title $id',
        artist: 'Artist $id',
        albumId: 'album$id',
        trackFileUrl: 'https://example.com/song$id.mp3',
      );
    });
  }
}

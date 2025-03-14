// services/mock_data.dart
import '../data/models/album.dart';
import '../data/models/song.dart';
import '../data/models/playlist.dart';

class MockData {
  static List<Album> getLatestAlbums() {
    return [
      Album(
        id: 'album1',
        title: 'Pain',
        artist: 'Chris Jones',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_1.jpg',
        releaseDate: DateTime(2025, 1, 10),
      ),
      Album(
        id: 'album2',
        title: 'Winter Love',
        artist: 'Alice Kim',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_2.jpg',
        releaseDate: DateTime(2025, 2, 14),
      ),
      Album(
        id: 'album3',
        title: 'Autumn Breeze',
        artist: 'Bob Lee',
        genre: 'hiphop',
        coverUrl: 'https://example.com/album_cover_3.jpg',
        releaseDate: DateTime(2025, 3, 20),
      ),
      Album(
        id: 'album4',
        title: 'Spring Bloom',
        artist: 'Jane Park',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_4.jpg',
        releaseDate: DateTime(2025, 4, 5),
      ),
      Album(
        id: 'album5',
        title: 'Night Sky',
        artist: 'Mason Lee',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_5.jpg',
        releaseDate: DateTime(2025, 5, 30),
      ),
      Album(
        id: 'album6',
        title: 'Sunny Days',
        artist: 'Ellen Kim',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_6.jpg',
        releaseDate: DateTime(2025, 6, 15),
      ),
      Album(
        id: 'album7',
        title: 'Rainy Mood',
        artist: 'Mark Choi',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_7.jpg',
        releaseDate: DateTime(2025, 7, 22),
      ),
      Album(
        id: 'album8',
        title: 'Ocean Waves',
        artist: 'Lily Chen',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_8.jpg',
        releaseDate: DateTime(2025, 8, 3),
      ),
      Album(
        id: 'album9',
        title: 'Mountain High',
        artist: 'Sam Woo',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_9.jpg',
        releaseDate: DateTime(2025, 9, 18),
      ),
      Album(
        id: 'album10',
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
        id: 'album11',
        title: 'Summer Vibes',
        artist: 'DJ Max',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_11.jpg',
        releaseDate: DateTime(2024, 6, 1),
      ),
      Album(
        id: 'album12',
        title: 'Golden Hits',
        artist: 'Various Artists',
        genre: 'jazz',
        coverUrl: 'https://example.com/album_cover_12.jpg',
        releaseDate: DateTime(2023, 12, 1),
      ),
      Album(
        id: 'album13',
        title: 'Rhythm Nation',
        artist: 'Beat Crew',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_13.jpg',
        releaseDate: DateTime(2024, 1, 15),
      ),
      Album(
        id: 'album14',
        title: 'Electric Pulse',
        artist: 'Neon Lights',
        genre: 'band',

        coverUrl: 'https://example.com/album_cover_14.jpg',
        releaseDate: DateTime(2024, 2, 28),
      ),
      Album(
        id: 'album15',
        title: 'Vintage Vibes',
        artist: 'Retro Beats',
        genre: 'jazz',

        coverUrl: 'https://example.com/album_cover_15.jpg',
        releaseDate: DateTime(2024, 3, 10),
      ),
      Album(
        id: 'album16',
        title: 'Rock Anthem',
        artist: 'The Strikers',
        genre: 'acoustic',

        coverUrl: 'https://example.com/album_cover_16.jpg',
        releaseDate: DateTime(2024, 4, 20),
      ),
      Album(
        id: 'album17',
        title: 'Indie Dreams',
        artist: 'Dreamers',
        genre: 'rnb',

        coverUrl: 'https://example.com/album_cover_17.jpg',
        releaseDate: DateTime(2024, 5, 5),
      ),
      Album(
        id: 'album18',
        title: 'Pop Explosion',
        artist: 'Starburst',
        genre: 'hiphop',

        coverUrl: 'https://example.com/album_cover_18.jpg',
        releaseDate: DateTime(2024, 6, 18),
      ),
      Album(
        id: 'album19',
        title: 'Folk Tales',
        artist: 'The Wanderers',
        genre: 'rnb',

        coverUrl: 'https://example.com/album_cover_19.jpg',
        releaseDate: DateTime(2024, 7, 30),
      ),
      Album(
        id: 'album20',
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
        id: 'playlist1',
        title: 'Top 50 K-Pop',
        coverUrl: 'https://example.com/playlist_cover_1.jpg',
        songIds: ['song1', 'song2', 'song3'],
      ),
      Playlist(
        id: 'playlist2',
        title: 'Relaxing Jazz',
        coverUrl: 'https://example.com/playlist_cover_2.jpg',
        songIds: ['song4', 'song5'],
      ),
      Playlist(
        id: 'playlist3',
        title: 'Rock Classics',
        coverUrl: 'https://example.com/playlist_cover_3.jpg',
        songIds: ['song6', 'song7', 'song8'],
      ),
      Playlist(
        id: 'playlist4',
        title: 'Hip Hop Beats',
        coverUrl: 'https://example.com/playlist_cover_4.jpg',
        songIds: ['song9', 'song10', 'song11'],
      ),
      Playlist(
        id: 'playlist5',
        title: 'Indie Mix',
        coverUrl: 'https://example.com/playlist_cover_5.jpg',
        songIds: ['song12', 'song13'],
      ),
      Playlist(
        id: 'playlist6',
        title: 'Workout Mix',
        coverUrl: 'https://example.com/playlist_cover_6.jpg',
        songIds: ['song14', 'song15', 'song16'],
      ),
      Playlist(
        id: 'playlist7',
        title: 'Chill Vibes',
        coverUrl: 'https://example.com/playlist_cover_7.jpg',
        songIds: ['song17', 'song18', 'song19'],
      ),
      Playlist(
        id: 'playlist8',
        title: 'Party Hits',
        coverUrl: 'https://example.com/playlist_cover_8.jpg',
        songIds: ['song20', 'song21', 'song22'],
      ),
      Playlist(
        id: 'playlist9',
        title: 'Acoustic Sessions',
        coverUrl: 'https://example.com/playlist_cover_9.jpg',
        songIds: ['song23', 'song24'],
      ),
      Playlist(
        id: 'playlist10',
        title: 'Electronic Essentials',
        coverUrl: 'https://example.com/playlist_cover_10.jpg',
        songIds: ['song25', 'song26', 'song27'],
      ),
    ];
  }

  static List<Song> getHot20Songs() {
    return [
      Song(
        id: 'song1',
        title: 'Too Bad (feat. Anders)',
        artist: 'G-DRAGON',
        albumId: 'album1',
        audioUrl: 'https://example.com/song1.mp3',
      ),
      Song(
        id: 'song2',
        title: 'Looking For Love (Lee Dagger Dub)',
        artist: 'G-DRAGON',
        albumId: 'album1',
        audioUrl: 'https://example.com/song2.mp3',
      ),
      Song(
        id: 'song3',
        title: 'Firestarter',
        artist: 'The Prodigy',
        albumId: 'album2',
        audioUrl: 'https://example.com/song3.mp3',
      ),
      Song(
        id: 'song4',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        albumId: 'album3',
        audioUrl: 'https://example.com/song4.mp3',
      ),
      Song(
        id: 'song5',
        title: 'Levitating',
        artist: 'Dua Lipa',
        albumId: 'album4',
        audioUrl: 'https://example.com/song5.mp3',
      ),
      Song(
        id: 'song6',
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        albumId: 'album5',
        audioUrl: 'https://example.com/song6.mp3',
      ),
      Song(
        id: 'song7',
        title: 'Uptown Funk',
        artist: 'Bruno Mars',
        albumId: 'album6',
        audioUrl: 'https://example.com/song7.mp3',
      ),
      Song(
        id: 'song8',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        albumId: 'album7',
        audioUrl: 'https://example.com/song8.mp3',
      ),
      Song(
        id: 'song9',
        title: 'Rolling in the Deep',
        artist: 'Adele',
        albumId: 'album8',
        audioUrl: 'https://example.com/song9.mp3',
      ),
      Song(
        id: 'song10',
        title: 'Viva La Vida',
        artist: 'Coldplay',
        albumId: 'album9',
        audioUrl: 'https://example.com/song10.mp3',
      ),
      Song(
        id: 'song1',
        title: 'Too Bad (feat. Anders)',
        artist: 'G-DRAGON',
        albumId: 'album1',
        audioUrl: 'https://example.com/song1.mp3',
      ),
      Song(
        id: 'song2',
        title: 'Looking For Love (Lee Dagger Dub)',
        artist: 'G-DRAGON',
        albumId: 'album1',
        audioUrl: 'https://example.com/song2.mp3',
      ),
      Song(
        id: 'song3',
        title: 'Firestarter',
        artist: 'The Prodigy',
        albumId: 'album2',
        audioUrl: 'https://example.com/song3.mp3',
      ),
      Song(
        id: 'song4',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        albumId: 'album3',
        audioUrl: 'https://example.com/song4.mp3',
      ),
      Song(
        id: 'song5',
        title: 'Levitating',
        artist: 'Dua Lipa',
        albumId: 'album4',
        audioUrl: 'https://example.com/song5.mp3',
      ),
      Song(
        id: 'song6',
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        albumId: 'album5',
        audioUrl: 'https://example.com/song6.mp3',
      ),
      Song(
        id: 'song7',
        title: 'Uptown Funk',
        artist: 'Bruno Mars',
        albumId: 'album6',
        audioUrl: 'https://example.com/song7.mp3',
      ),
      Song(
        id: 'song8',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        albumId: 'album7',
        audioUrl: 'https://example.com/song8.mp3',
      ),
      Song(
        id: 'song9',
        title: 'Rolling in the Deep',
        artist: 'Adele',
        albumId: 'album8',
        audioUrl: 'https://example.com/song9.mp3',
      ),
      Song(
        id: 'song10',
        title: 'Viva La Vida',
        artist: 'Coldplay',
        albumId: 'album9',
        audioUrl: 'https://example.com/song10.mp3',
      ),
    ];
  }
}

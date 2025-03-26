import 'package:ari/data/datasources/playlist/playlist_mock_datasource.dart';
import 'package:ari/data/models/playlist.dart';

abstract class IPlaylistRepository {
  Future<List<Playlist>> fetchPlaylists();
}

class PlaylistRepositoryImpl implements IPlaylistRepository {
  final PlaylistMockDataSource mockDataSource;

  PlaylistRepositoryImpl(this.mockDataSource);

  @override
  Future<List<Playlist>> fetchPlaylists() {
    return mockDataSource.fetchPlaylists();
  }
}

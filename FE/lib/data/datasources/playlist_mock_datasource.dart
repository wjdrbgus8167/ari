// lib/data/datasources/playlist_mock_datasource.dart
import 'package:ari/data/models/playlist.dart';
import 'package:ari/dummy_data/mock_playlist_data.dart';

class PlaylistMockDataSource {
  Future<List<Playlist>> fetchPlaylists() async {
    // 실제 API 호출 대신, Mock 데이터를 반환
    await Future.delayed(const Duration(milliseconds: 500));
    // API 호출 대기 시뮬레이션
    return MockPlaylistData.getMockPlaylists();
  }
}

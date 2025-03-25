import 'package:ari/domain/entities/playlist.dart';

abstract class IPlaylistRepository {
  Future<List<Playlist>> fetchPlaylists();
  Future<void> deleteTrack(int playlistId, int trackId);
}

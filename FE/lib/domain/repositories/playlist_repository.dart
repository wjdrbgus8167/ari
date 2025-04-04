import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/domain/entities/playlist.dart';

abstract class IPlaylistRepository {
  Future<List<Playlist>> fetchPlaylists();
  Future<Playlist> createPlaylist(PlaylistCreateRequest request);
  Future<void> addTrack(int playlistId, int trackId);
  Future<void> deleteTrack(int playlistId, int trackId);
  Future<Playlist> getPlaylistDetail(int playlistId);
}

import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/domain/entities/playlist.dart' as domain;
import 'package:ari/domain/repositories/playlist_repository.dart';
import 'package:ari/data/mappers/playlist_mapper.dart';

class PlaylistRepositoryImpl implements IPlaylistRepository {
  final IPlaylistRemoteDataSource remoteDataSource;

  PlaylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<domain.Playlist>> fetchPlaylists() async {
    final dataPlaylists = await remoteDataSource.fetchPlaylists();
    return dataPlaylists.map(mapDataPlaylistToDomain).toList();
  }

  @override
  Future<domain.Playlist> createPlaylist(PlaylistCreateRequest request) async {
    final dataPlaylist = await remoteDataSource.createPlaylist(request);
    return mapDataPlaylistToDomain(dataPlaylist);
  }

  @override
  Future<void> addTrack(int playlistId, int trackId) {
    return remoteDataSource.addTrack(playlistId, trackId);
  }

  @override
  Future<void> deleteTrack(int playlistId, int trackId) {
    return remoteDataSource.deleteTrack(playlistId, trackId);
  }
}

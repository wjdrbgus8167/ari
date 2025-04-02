// lib/data/repositories/playlist_repository_impl.dart
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/domain/repositories/playlist_repository.dart';
import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/mappers/playlist_mapper.dart';

class PlaylistRepositoryImpl implements IPlaylistRepository {
  final IPlaylistRemoteDataSource remoteDataSource;

  PlaylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Playlist>> fetchPlaylists() async {
    final dataModels = await remoteDataSource.fetchPlaylists();
    return dataModels.map((model) => toEntity(model)).toList();
  }

  @override
  Future<Playlist> getPlaylistDetail(int playlistId) async {
    final dataModel = await remoteDataSource.getPlaylistDetail(playlistId);
    return toEntityForDetail(dataModel);
  }

  @override
  Future<Playlist> createPlaylist(PlaylistCreateRequest request) async {
    final dataModel = await remoteDataSource.createPlaylist(request);
    return toEntity(dataModel);
  }

  @override
  Future<void> addTrack(int playlistId, int trackId) async {
    return await remoteDataSource.addTrack(playlistId, trackId);
  }

  @override
  Future<void> deleteTrack(int playlistId, int trackId) async {
    return await remoteDataSource.deleteTrack(playlistId, trackId);
  }

  @override
  Future<void> deletePlaylist(int playlistId) async {
    return await remoteDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<void> reorderTracks(int playlistId, List<int> trackOrder) async {
    return await remoteDataSource.reorderTracks(playlistId, trackOrder);
  }

  @override
  Future<void> sharePlaylist(int playlistId) async {
    return await remoteDataSource.sharePlaylist(playlistId);
  }

  @override
  Future<List<Playlist>> fetchPopularPlaylists() async {
    final dataModels = await remoteDataSource.fetchPopularPlaylists();
    return dataModels.map((model) => toEntity(model)).toList();
  }
}

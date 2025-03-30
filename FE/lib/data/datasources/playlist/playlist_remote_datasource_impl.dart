import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:dio/dio.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/models/playlist.dart';

class PlaylistRemoteDataSourceImpl implements IPlaylistRemoteDataSource {
  final Dio dio;

  PlaylistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Playlist>> fetchPlaylists() async {
    final response = await dio.get('/api/v1/playlists');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Playlist.fromJson(json)).toList();
  }

  @override
  Future<Playlist> getPlaylistDetail(int playlistId) async {
    final response = await dio.get('/api/v1/playlists/$playlistId');
    final data = response.data['data'];
    return Playlist.fromJson(data);
  }

  @override
  Future<Playlist> createPlaylist(PlaylistCreateRequest data) async {
    final response = await dio.post(
      '$baseUrl/api/v1/playlists',
      data: data.toJson(),
    );
    final created = response.data['data'];
    return Playlist.fromJson(created);
  }

  @override
  Future<void> addTrack(int playlistId, int trackId) async {
    await dio.post(
      '$baseUrl/api/v1/playlists/$playlistId/tracks',
      data: {"trackId": trackId},
    );
  }

  @override
  Future<void> deleteTrack(int playlistId, int trackId) async {
    await dio.delete('$baseUrl/api/v1/playlists/$playlistId/tracks/$trackId');
  }

  @override
  Future<void> deletePlaylist(int playlistId) async {
    await dio.delete('$baseUrl/api/v1/playlists/$playlistId');
  }

  @override
  Future<void> reorderTracks(int playlistId, List<int> trackOrder) async {
    await dio.put(
      '$baseUrl/api/v1/playlists/$playlistId/tracks',
      data: {"order": trackOrder},
    );
  }

  @override
  Future<void> sharePlaylist(int playlistId) async {
    await dio.post(
      '$baseUrl/api/v1/playlists/share',
      data: {"playlistId": playlistId},
    );
  }
}

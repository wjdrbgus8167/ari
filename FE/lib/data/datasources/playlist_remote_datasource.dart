import 'package:dio/dio.dart';
import 'package:ari/core/constants/app_constants.dart';
import 'package:ari/data/models/playlist.dart';

class PlaylistRemoteDataSource {
  final Dio dio;

  PlaylistRemoteDataSource({required this.dio});

  Future<List<Playlist>> fetchPlaylists() async {
    final response = await dio.get('${baseUrl}/api/v1/playlists');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Playlist.fromJson(json)).toList();
  }
}

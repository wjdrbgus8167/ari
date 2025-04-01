import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/data/models/playlist.dart';
import 'package:dio/dio.dart';

class PlaylistRemoteDataSourceImpl implements IPlaylistRemoteDataSource {
  final Dio dio;

  PlaylistRemoteDataSourceImpl({required this.dio});

  /// 내부적으로 API 요청을 수행하고, 응답 데이터를 지정된 fromJson 함수로 변환합니다.
  Future<T> _request<T>({
    required String url,
    required String method,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      Response response;
      switch (method) {
        case 'GET':
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'PUT':
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'DELETE':
          response = await dio.delete(url, queryParameters: queryParameters);
          break;
        default:
          throw Failure(message: '지원하지 않는 HTTP 메서드입니다: $method');
      }

      // API 응답을 ApiResponse 모델로 변환
      final apiResponse = ApiResponse.fromJson(response.data, fromJson);

      // 오류 발생 시 Failure 예외를 던짐
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: response.statusCode,
        );
      }

      return apiResponse.data as T;
    } on DioException catch (e) {
      throw Failure(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '😞 알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 플레이리스트 목록 조회
  @override
  Future<List<Playlist>> fetchPlaylists() async {
    return _request<List<Playlist>>(
      url: '/api/v1/playlists',
      method: 'GET',
      fromJson: (data) {
        final List<dynamic> list = data as List<dynamic>;
        return list.map((json) => Playlist.fromJson(json)).toList();
      },
    );
  }

  /// 플레이리스트 상세 조회
  @override
  Future<Playlist> getPlaylistDetail(int playlistId) async {
    return _request<Playlist>(
      url: '/api/v1/playlists/$playlistId',
      method: 'GET',
      fromJson: (data) => Playlist.fromJson(data),
    );
  }

  /// 플레이리스트 생성
  @override
  Future<Playlist> createPlaylist(PlaylistCreateRequest request) async {
    return _request<Playlist>(
      url: '/api/v1/playlists',
      method: 'POST',
      data: request.toJson(),
      fromJson: (data) => Playlist.fromJson(data),
    );
  }

  /// 플레이리스트에 트랙 추가
  @override
  Future<void> addTrack(int playlistId, int trackId) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId/tracks',
      method: 'POST',
      data: {"trackId": trackId},
      fromJson: (_) {},
    );
  }

  /// 플레이리스트에서 트랙 삭제
  @override
  Future<void> deleteTrack(int playlistId, int trackId) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId/tracks/$trackId',
      method: 'DELETE',
      fromJson: (_) {},
    );
  }

  /// 플레이리스트 삭제
  @override
  Future<void> deletePlaylist(int playlistId) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId',
      method: 'DELETE',
      fromJson: (_) {},
    );
  }

  /// 플레이리스트 트랙 순서 변경
  @override
  Future<void> reorderTracks(int playlistId, List<int> trackOrder) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId/tracks',
      method: 'PUT',
      data: {"order": trackOrder},
      fromJson: (_) {},
    );
  }

  /// 플레이리스트 공유
  @override
  Future<void> sharePlaylist(int playlistId) async {
    await _request<void>(
      url: '/api/v1/playlists/share',
      method: 'POST',
      data: {"playlistId": playlistId},
      fromJson: (_) {},
    );
  }

  /// 플레이리스트를 공개로 전환
  @override
  Future<void> publishPlaylist(int playlistId) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId/publiced',
      method: 'PUT',
      fromJson: (_) {},
    );
  }

  /// 인기 플레이리스트 조회
  @override
  Future<List<Playlist>> fetchPopularPlaylists() async {
    return _request<List<Playlist>>(
      url: '/api/v1/playlists/popular',
      method: 'GET',
      fromJson: (data) {
        final List<dynamic> list = data as List<dynamic>;
        return list.map((json) => Playlist.fromJson(json)).toList();
      },
    );
  }
}

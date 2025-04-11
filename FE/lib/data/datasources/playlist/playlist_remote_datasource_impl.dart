import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/playlist_trackitem.dart';
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
      print('[DEBUG] 요청 URL: $url');
      print('[DEBUG] 요청 메서드: $method');
      print('[DEBUG] 요청 데이터: $data');

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
        final dynamic playlistsData = data['playlists'];
        if (playlistsData is List) {
          return playlistsData.map((json) => Playlist.fromJson(json)).toList();
        } else if (playlistsData is Map<String, dynamic>) {
          return [Playlist.fromJson(playlistsData)];
        } else {
          return [];
        }
      },
    );
  }

  /// 플레이리스트 상세 조회
  @override
  Future<Playlist> getPlaylistDetail(int playlistId) async {
    return _request<Playlist>(
      url: '/api/v1/playlists/$playlistId',
      method: 'GET',
      fromJson: (data) {
        // ApiResponse 내부에서 이미 "data" 필드만 전달받으므로,
        // data는 {"tracks": [...]} 형태입니다.
        final dataMap = data as Map<String, dynamic>;
        final tracksData = dataMap['tracks'] as List<dynamic>;
        final tracks =
            tracksData
                .map(
                  (json) =>
                      PlaylistTrackItem.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        print('getPlaylistDetail: Parsed tracks count = ${tracks.length}');
        print('tracks$tracks');
        // 상세조회 API는 트랙 목록만 반환하므로, 기본 정보는 빈 값 또는 기본값으로 지정합니다.
        return Playlist(
          id: playlistId,
          artist: '', // 기본값, ViewModel에서 병합할 예정
          title: '', // 기본값, ViewModel에서 목록 데이터와 병합할 예정
          coverImageUrl: '', // 기본값, ViewModel에서 병합할 예정
          isPublic: false, // 기본값, ViewModel에서 병합할 예정
          shareCount: 0, // 기본값, ViewModel에서 병합할 예정
          trackCount: tracks.length,
          tracks: tracks,
        );
      },
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
      data: {
        "tracks": [
          {"trackId": trackId},
        ],
      },
      fromJson: (_) {},
    );
  }

  /// 플레이리스트에 여러 트랙 추가
  @override
  Future<void> addTracks(int playlistId, List<int> trackIds) async {
    await _request<void>(
      url: '/api/v1/playlists/$playlistId/tracks',
      method: 'POST',
      data: {
        "tracks": trackIds.map((id) => {"trackId": id}).toList(),
      },
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

  /// 플레이리스트 퍼가기
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
        print('🌍 fetchPopularPlaylists - data: $data'); // ✅ 여기에 추가

        // data는 이미 API 응답의 data 필드를 전달받은 것으로 가정 (즉, data: { "playlists": [...] } )
        final dynamic playlistsData = data['playlists'];
        if (playlistsData is List) {
          return playlistsData.map((json) => Playlist.fromJson(json)).toList();
        } else {
          return [];
        }
      },
    );
  }
}

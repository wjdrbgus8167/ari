import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/failure.dart';
import '../../models/api_response.dart';
import '../../models/my_channel/channel_info.dart';
import '../../models/my_channel/artist_album.dart';
import '../../models/my_channel/artist_notice.dart';
import '../../models/my_channel/fantalk.dart';
import '../../models/my_channel/public_playlist.dart';
import '../../models/my_channel/neighbor.dart';
import 'my_channel_remote_datasource.dart';

/// 나의 채널 관련 API 호출 실제로! 수행
/// Dio -> HTTP 요청 -> 서버로부터 This 데이터를 받아오고 모델로 변환
class MyChannelRemoteDataSourceImpl implements MyChannelRemoteDataSource {
  /// Dio HTTP 클라이언트
  final Dio dio;

  /// [dio] : Dio HTTP 클라이언트 객체
  /// 인증 인터셉터 설정된 dio 객체 사용
  MyChannelRemoteDataSourceImpl({required this.dio}) {
    // 기본 URL과 타임아웃 설정은 Provider에서 이미 설정되었음
    // 인증 토큰은 AuthInterceptor에서 자동으로 헤더에 추가됨
  }

  /// API 요청 처리, 결과를 반환
  /// [url] : API 엔드포인트 URL
  /// [method] : HTTP 메서드 (GET, POST, DELETE 등)
  /// [fromJson] : API 응답 데이터를 객체로 변환하는 함수
  /// [queryParameters] : URL 쿼리 파라미터
  /// [data] : 요청 본문 데이터
  /// [return] : 응답 데이터를 변환한 객체
  /// [throws] : Failure 객체 (오류 발생 시)
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
        case 'DELETE':
          response = await dio.delete(url, queryParameters: queryParameters);
          break;
        default:
          throw Failure(message: '지원하지 않는 HTTP 메서드입니다: $method');
      }

      // API 응답 처리
      final apiResponse = ApiResponse.fromJson(response.data, fromJson);

      // 오류 check
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      // 응답 데이터 반환
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
      throw Failure(message: '😞알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 채널 정보 조회
  @override
  Future<ChannelInfo> getChannelInfo(String memberId) async {
    return _request<ChannelInfo>(
      url: '/api/v1/members/$memberId/channel-info',
      method: 'GET',
      fromJson: (data) => ChannelInfo.fromJson(data),
    );
  }

  /// 회원 팔로우
  @override
  Future<void> followMember(String memberId) async {
    await _request<void>(
      url: '/api/v1/follows/members/$memberId',
      method: 'POST',
      fromJson: (_) {}, // 데이터 없으므로 null 반환
    );
  }

  /// 회원 언팔로우
  @override
  Future<void> unfollowMember(String followId) async {
    await _request<void>(
      url: '/api/v1/follows/$followId',
      method: 'DELETE',
      fromJson: (_) {}, // 데이터 없으므로 null 반환
    );
  }

  /// 아티스트 앨범 목록 조회
  @override
  Future<List<ArtistAlbum>> getArtistAlbums(String memberId) async {
    return _request<List<ArtistAlbum>>(
      url: '/api/v1/artists/$memberId/albums',
      method: 'GET',
      fromJson: (data) {
        // API 응답에서 앨범 배열을 직접 파싱
        // 여기서 data는 이미 ApiResponse의 data 필드 값
        if (data is List) {
          // 이미 List 형태로 넘어온 경우
          return data
              .map((albumJson) => ArtistAlbum.fromJson(albumJson))
              .toList();
        } else if (data is Map && data.containsKey('albums')) {
          // 'albums' 키가 있는 경우 (API 응답 구조가 변경될 수 있음)
          final albumsList = data['albums'] as List<dynamic>;
          return albumsList
              .map((albumJson) => ArtistAlbum.fromJson(albumJson))
              .toList();
        } else {
          // 빈 리스트 반환
          print('❌ 예상치 못한 API 응답 형식: $data');
          return [];
        }
      },
    );
  }

  /// 아티스트 공지사항 조회
  @override
  Future<ArtistNoticeResponse> getArtistNotices(String memberId) async {
    return _request<ArtistNoticeResponse>(
      url: '/api/v1/artists/$memberId/notices',
      method: 'GET',
      fromJson: (data) => ArtistNoticeResponse.fromJson(data),
    );
  }

  /// 팬톡 목록 조회
  @override
  Future<FanTalkResponse> getFanTalks(String fantalkChannelId) async {
    return _request<FanTalkResponse>(
      url: '/api/v1/fantalk-channels/$fantalkChannelId/fantalks',
      method: 'GET',
      fromJson: (data) => FanTalkResponse.fromJson(data),
    );
  }

  /// 공개된 플레이리스트 조회
  @override
  Future<PublicPlaylistResponse> getPublicPlaylists(String memberId) async {
    return _request<PublicPlaylistResponse>(
      url: '/api/v1/playlists/public',
      method: 'GET',
      queryParameters: {'memberId': memberId},
      fromJson: (data) => PublicPlaylistResponse.fromJson(data),
    );
  }

  /// 팔로워 목록 조회
  @override
  Future<FollowerResponse> getFollowers(String memberId) async {
    return _request<FollowerResponse>(
      url: '/api/v1/follows/members/$memberId/follower/list',
      method: 'GET',
      fromJson: (data) => FollowerResponse.fromJson(data),
    );
  }

  /// 팔로잉 목록 조회
  @override
  Future<FollowingResponse> getFollowings(String memberId) async {
    return _request<FollowingResponse>(
      url: '/api/v1/follows/members/$memberId/following/list',
      method: 'GET',
      fromJson: (data) => FollowingResponse.fromJson(data),
    );
  }
}

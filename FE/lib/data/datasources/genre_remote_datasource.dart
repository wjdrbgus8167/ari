import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/album.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:dio/dio.dart';

class GenreRemoteDataSource {
  final Dio dio;

  GenreRemoteDataSource({required this.dio});

  // 장르에 따른 실제 API ID 반환 메서드
  int _getApiGenreId(Genre genre) {
    switch (genre) {
      case Genre.hiphop:
        return 1; // 힙합
      case Genre.acoustic:
        return 2; // 어쿠스틱
      case Genre.jazz:
        return 3; // 재즈
      case Genre.band:
        return 4; // 밴드
      case Genre.rnb:
        return 5; // 알앤비
      case Genre.all:
      default:
        return 1; // 기본값으로 힙합 반환
    }
  }

  /// 장르별 인기 차트 조회 (30일 내 데이터, 1시간마다 갱신)
  /// [genre] 장르 타입
  Future<List<ChartItem>> fetchGenreCharts(Genre genre) async {
    final genreId = _getApiGenreId(genre);
    final url = '/api/v1/charts/genres/$genreId';
    // print('🌐 API 호출: $url');

    try {
      final response = await dio.get(url);
      // print('✅ 차트 응답 상태 코드: ${response.statusCode}');

      final apiResponse = ApiResponse.fromJson(response.data, (data) {
        if (data['charts'] == null) {
          // print('⚠️ 차트 데이터가 없음');
          return <ChartItem>[];
        }

        final chartsJson = data['charts'] as List? ?? [];
        return chartsJson.map((c) => ChartItem.fromJson(c)).toList();
      });

      if (apiResponse.status == 200) {
        final result = apiResponse.data ?? [];
        // print('📊 차트 데이터 개수: ${result.length}');
        return result;
      } else {
        // print('❌ API 응답 오류: ${apiResponse.message}');
        throw Failure(message: '장르별 차트 데이터 조회 실패: ${apiResponse.message}');
      }
    } catch (e) {
      // print('❌ 차트 API 호출 실패: $e');
      if (e is DioException) {
        // 상세 오류 로깅
        // print('❌ 상태 코드: ${e.response?.statusCode}');
        // print('❌ 응답 데이터: ${e.response?.data}');

        // 데이터 없음은 정상 처리 (빈 결과 반환)
        if (e.response?.statusCode == 404) {
          // print('⚠️ 해당 장르의 차트가 없습니다 (404)');
          return [];
        }

        throw Failure(message: '네트워크 에러: ${e.message}');
      }
      throw Failure(message: '차트 데이터 조회 중 오류 발생: $e');
    }
  }

  /// 장르별 인기 트랙 조회 (7일 내 데이터, 매일 오전 6시 갱신)
  /// [genre] 장르 타입
  Future<List<Track>> fetchGenrePopularTracks(Genre genre) async {
    final genreId = _getApiGenreId(genre);
    final url = '/api/v1/tracks/genres/$genreId/popular';
    // print('🌐 API 호출: $url');

    try {
      final response = await dio.get(url);
      // print('✅ 인기트랙 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tracksJson = response.data['data']['tracks'] as List? ?? [];
        final tracks =
            tracksJson.map((trackJson) => Track.fromJson(trackJson)).toList();
        // print('🎵 인기 트랙 개수: ${tracks.length}');
        return tracks;
      } else {
        // print('❌ 인기트랙 API 응답 오류: ${response.statusCode}');
        throw Failure(message: '장르별 인기 트랙 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ 인기트랙 API 호출 실패: $e');
      if (e is DioException) {
        // print('❌ 상태 코드: ${e.response?.statusCode}');
        // print('❌ 응답 데이터: ${e.response?.data}');

        // 데이터 없음은 정상 처리 (빈 결과 반환)
        if (e.response?.statusCode == 404) {
          // print('⚠️ 해당 장르의 인기 트랙이 없습니다 (404)');
          return [];
        }

        throw Failure(message: '네트워크 에러: ${e.message}');
      }
      throw Failure(message: '인기 트랙 조회 중 오류 발생: $e');
    }
  }

  /// 장르별 신규 앨범 조회
  /// [genre] 장르 타입
  Future<List<Album>> fetchGenreNewAlbums(Genre genre) async {
    final genreId = _getApiGenreId(genre);
    final url = '/api/v1/albums/genres/$genreId/new';
    // print('🌐 API 호출: $url');

    try {
      final response = await dio.get(url);
      // print('✅ 신규앨범 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final albumsJson = response.data['data']['albums'] as List? ?? [];
        final albums =
            albumsJson.map((albumJson) => Album.fromJson(albumJson)).toList();
        // print('💿 신규 앨범 개수: ${albums.length}');
        return albums;
      } else {
        // print('❌ 신규앨범 API 응답 오류: ${response.statusCode}');
        throw Failure(message: '장르별 신규 앨범 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ 신규앨범 API 호출 실패: $e');
      if (e is DioException) {
        // print('❌ 상태 코드: ${e.response?.statusCode}');
        // print('❌ 응답 데이터: ${e.response?.data}');

        // 데이터 없음은 정상 처리 (빈 결과 반환)
        if (e.response?.statusCode == 404) {
          // print('⚠️ 해당 장르의 신규 앨범이 없습니다 (404)');
          return [];
        }

        throw Failure(message: '네트워크 에러: ${e.message}');
      }
      throw Failure(message: '신규 앨범 조회 중 오류 발생: $e');
    }
  }

  /// 장르별 인기 앨범 조회
  /// [genre] 장르 타입
  Future<List<Album>> fetchGenrePopularAlbums(Genre genre) async {
    final genreId = _getApiGenreId(genre);
    final url = '/api/v1/albums/genres/$genreId/popular';
    // print('🌐 API 호출: $url');

    try {
      final response = await dio.get(url);
      // print('✅ 인기앨범 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final albumsJson = response.data['data']['albums'] as List? ?? [];
        final albums =
            albumsJson.map((albumJson) => Album.fromJson(albumJson)).toList();
        // print('💿 인기 앨범 개수: ${albums.length}');
        return albums;
      } else {
        // print('❌ 인기앨범 API 응답 오류: ${response.statusCode}');
        throw Failure(message: '장르별 인기 앨범 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ 인기앨범 API 호출 실패: $e');
      if (e is DioException) {
        // print('❌ 상태 코드: ${e.response?.statusCode}');
        // print('❌ 응답 데이터: ${e.response?.data}');

        // 데이터 없음은 정상 처리 (빈 결과 반환)
        if (e.response?.statusCode == 404) {
          // print('⚠️ 해당 장르의 인기 앨범이 없습니다 (404)');
          return [];
        }

        throw Failure(message: '네트워크 에러: ${e.message}');
      }
      throw Failure(message: '인기 앨범 조회 중 오류 발생: $e');
    }
  }
}

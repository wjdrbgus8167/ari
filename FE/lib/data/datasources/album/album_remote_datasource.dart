import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/album.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:dio/dio.dart';

abstract class AlbumDataSource {
  Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId);

  // 인기 앨범 목록을 가져오는 메서드 추가
  Future<List<Album>> fetchPopularAlbums();

  // 최신 앨범 목록을 가져오는 메서드 추가
  Future<List<Album>> fetchLatestAlbums();
}

class AlbumDataSourceImpl implements AlbumDataSource {
  final Dio dio;

  AlbumDataSourceImpl({required this.dio});

  @override
  Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId) async {
    final url = '/api/v1/albums/$albumId';
    try {
      // Dio를 사용하여 GET 요청 보내기
      final response = await dio.get(url);
      print("파싱 : ${AlbumDetailModel.fromJson(response.data['data'])}");
      // ApiResponse 객체로 변환
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => AlbumDetailModel.fromJson(json),
      );
      print("datasource 2");
      if (apiResponse.status == 200) {
        print("datasource return");
        return apiResponse;
      } else {
        throw Failure(message: "에러가 났음요");
      }
    } catch (e) {
      // DioError 또는 기타 예외 처리
      if (e is DioException) {
        // Dio 에러 정보를 사용하여 에러 응답 생성
        throw Failure(message: "에러가 났음요");
      } else {
        // 기타 예외 처리
        throw Failure(message: "에러가 났음요");
      }
    }
  }

  @override
  Future<List<Album>> fetchPopularAlbums() async {
    try {
      final response = await dio.get('/api/v1/albums/popular');
      if (response.statusCode == 200) {
        final albumsJson = response.data['data']['albums'] as List;
        return albumsJson
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();
      } else {
        throw Failure(message: "인기 앨범 로드 실패: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        throw Failure(message: "네트워크 에러 발생: ${e.message}");
      } else {
        throw Failure(message: "알 수 없는 에러 발생: $e");
      }
    }
  }

  @override
  Future<List<Album>> fetchLatestAlbums() async {
    try {
      final response = await dio.get('/api/v1/albums/new');
      if (response.statusCode == 200) {
        final albumsJson = response.data['data']['albums'] as List;
        return albumsJson
            .map((albumJson) => Album.fromJson(albumJson))
            .toList();
      } else {
        throw Failure(message: "최신 앨범 로드 실패: ${response.statusCode}");
      }
    } catch (e) {
      if (e is DioException) {
        throw Failure(message: "네트워크 에러 발생: ${e.message}");
      } else {
        throw Failure(message: "알 수 없는 에러 발생: $e");
      }
    }
  }
}

// class AlbumMockDataSourceImpl implements AlbumDataSource {

//   final Dio dio;

//   AlbumMockDataSourceImpl({
//     required this.dio,
//   });

//   @override
//   Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 800));
    
//     final Map<String, dynamic> mockData = {
//       "status" : 200,
//       "message" : "Success",
//       "data": {
//         "albumId": 1,
//         "albumTitle": "hiyo",
//         "artist": "유캔도",
//         "composer": "김준석", 
//         "discription" : "이 앨범은....",
//         "genre": "호러",
//         "albumLikeCount" :12433,
//         "commentCount":180,
//         "rating" : "4.2",
//         "createdAt":"2024-08-12",
//         "coverImageUrl": "",
//         "comments" : [
//           {
//             "trackId" : 1,
//             "commentId":1,
//             "nickname":"hgg",
//             "content": "This track is amazing!",
//             "contentTimestamp": "01:25",
//             "createdAt":"2025-01-25"
//           },
//           {
//             "trackId" : 1,
//             "commentId":2,
//             "nickname":"yuio",
//             "content": "This track is amazing!",
//             "contentTimestamp": "01:25",
//             "createdAt":"2025-01-25"
//           },
//         ],
//       "track" : [
//           {
//             "trackId" : 1,
//             "trackTitle":"hi"
//           },
//           {
//             "trackId" : 2,
//             "trackTitle":"hi"
//           },
//         ]
//       }
//     };

//     await Future.delayed(Duration(milliseconds: 300));
//     print(ApiResponse.fromJson(mockData, (json) => AlbumDetailModel.fromJson(json)));
//     return ApiResponse.fromJson(mockData, (json) => AlbumDetailModel.fromJson(json));
//   }
// }
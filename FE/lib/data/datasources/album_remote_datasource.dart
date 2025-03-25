import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/album_detail.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:dio/dio.dart';

abstract class AlbumDataSource {
  Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId);
}

class AlbumDataSourceImpl implements AlbumDataSource {
  final Dio dio;
  final String baseUrl;

  AlbumDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId) async {
    final url = '$baseUrl/api/v1/albums/$albumId';
    try {
      // Dio를 사용하여 GET 요청 보내기
      final response = await dio.get(url);

      // ApiResponse 객체로 변환
      final apiResponse = ApiResponse.fromJson(response.data, (json) => AlbumDetailModel.fromJson(json));
      
      if (apiResponse.status == 200) {
        return apiResponse;
      } else {
        throw Failure.fromApiResponse(apiResponse);
      }
      
    } catch (e) {
      // DioError 또는 기타 예외 처리
      if (e is DioException) {
        // Dio 에러 정보를 사용하여 에러 응답 생성
        throw Failure.fromDioException(e);
      } else {
        // 기타 예외 처리
        throw Failure.fromException(e as Exception);
      }
    }
  }
}

class AlbumMockDataSourceImpl implements AlbumDataSource {

  final Dio dio;
  final String baseUrl;

  AlbumMockDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<ApiResponse<AlbumDetailModel>> getAlbumDetail(int albumId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final Map<String, dynamic> mockData = {
      "status" : 200,
      "message" : "Success",
      "data": {
        "albumId": 1,
        "albumTitle": "hiyo",
        "artist": "유캔도",
        "composer": "김준석", 
        "discription" : "이 앨범은....",
        "genre": "호러",
        "albumLikeCount" :12433,
        "commentCount":180,
        "rating" : "4.2",
        "createdAt":"2024-08-12",
        "coverImageUrl": "https://s3.example.com/tracks/track_one.mp3",
        "comments" : [
          {
            "trackId" : 1,
            "commentId":1,
            "nickname":"hgg",
            "content": "This track is amazing!",
            "contentTimestamp": "01:25",
            "createdAt":"2025-01-25"
          },
          {
            "trackId" : 1,
            "commentId":2,
            "nickname":"yuio",
            "content": "This track is amazing!",
            "contentTimestamp": "01:25",
            "createdAt":"2025-01-25"
          },
        ],
      "track" : [
          {
            "trackId" : 1,
            "trackTitle":"hi"
          },
          {
            "trackId" : 2,
            "trackTitle":"hi"
          },
        ]
      }
    };

    await Future.delayed(Duration(milliseconds: 300));
    print(ApiResponse.fromJson(mockData, (json) => AlbumDetailModel.fromJson(json)));
    return ApiResponse.fromJson(mockData, (json) => AlbumDetailModel.fromJson(json));
  }
}
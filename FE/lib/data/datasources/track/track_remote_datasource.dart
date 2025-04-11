import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/data/models/track_detail.dart';
import 'package:dio/dio.dart';

abstract class TrackDataSource {
  Future<ApiResponse<TrackDetailModel>> getTrackDetail(int albumId, int trackId);
}

class TrackDataSourceImpl implements TrackDataSource {
  final Dio dio;

  TrackDataSourceImpl({
    required this.dio,
  });

  @override
  Future<ApiResponse<TrackDetailModel>> getTrackDetail(int albumId, int trackId) async {
    final url = '/api/v1/albums/$albumId/tracks/$trackId';
    try {
      // Dio를 사용하여 GET 요청 보내기
      final response = await dio.get(url);

      // ApiResponse 객체로 변환
      final apiResponse = ApiResponse.fromJson(response.data, (json) => TrackDetailModel.fromJson(json));
      
      if (apiResponse.status == 200) {
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
}

class TrackMockDataSourceImpl implements TrackDataSource {

  final Dio dio;

  TrackMockDataSourceImpl({
    required this.dio,
  });

  @override
  Future<ApiResponse<TrackDetailModel>> getTrackDetail(int albumId, int trackId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final Map<String, dynamic> mockData = {
      "status" : 200,
      "message" : "Success",
      "data": {
        "trackId":1,
        "albumTitle": "hiyo",
        "trackTitle": "ahah",
        "artist": "유캔도",
        "composer": "김준석",
        "lyricist" : "김준석", 
        "trackLikeCount" :12433,
        "trackCommentCount":180,
        "createdAt":"2024-08-12",
        "lyric" : "나는있자나...",
        "trackFileUrl": "",
        "genreName": "발라드",
        "trackComments" : [
          {
            "memberId" : 1,
            "commentId":1,
            "nickname":"hgg",
            "content": "This track is amazing!",
            "timestamp": "01:25",
            "createdAt":"2025-01-25"
          },
          {
            "memberId" : 1,
            "commentId":2,
            "nickname":"hgg",
            "content": "This track is amazing!",
            "timestamp": "01:25",
            "createdAt":"2025-01-25"
          },
        ]
      }
    };

    await Future.delayed(Duration(milliseconds: 300));
      
    return ApiResponse.fromJson(mockData, (json) => TrackDetailModel.fromJson(json));
  }
}
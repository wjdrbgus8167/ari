import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../models/api_response.dart';
import '../../models/my_channel/artist_notice.dart';
import 'artist_notice_remote_datasource.dart';

class ArtistNoticeRemoteDataSourceImpl implements ArtistNoticeRemoteDataSource {
  final Dio dio;

  ArtistNoticeRemoteDataSourceImpl({required this.dio});

  /// 공지사항 목록 조회
  @override
  Future<ArtistNoticeResponse> getArtistNotices(String memberId) async {
    try {
      // API 엔드포인트 호출
      final response = await dio.get('/api/v1/artists/$memberId/notices');

      // API 응답 파싱
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => ArtistNoticeResponse.fromJson(data),
      );

      // 성공
      if (apiResponse.status == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        // 에러
        throw Failure(
          message: apiResponse.error?.message ?? '공지사항을 불러오는데 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}

// lib/data/datasources/my_channel/artist_notice_remote_datasource_impl.dart

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
      print('📝 공지사항 목록 조회 요청: memberId=$memberId');

      // API 엔드포인트 호출
      final response = await dio.get('/api/v1/artists/$memberId/notices');

      print('📝 공지사항 목록 응답 상태: ${response.statusCode}');
      print('📝 공지사항 목록 응답 데이터: ${response.data}');

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
        print('📝 공지사항 목록 조회 실패: ${apiResponse.message}');
        throw Failure(
          message: apiResponse.error?.message ?? '공지사항을 불러오는데 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('📝 공지사항 목록 조회 Dio 오류: ${e.message}');
      print('📝 응답 데이터: ${e.response?.data}');
      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('📝 공지사항 목록 조회 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 공지사항 상세 조회
  @override
  Future<ArtistNotice> getArtistNoticeDetail(int noticeId) async {
    try {
      print('📝 공지사항 상세 조회 요청: noticeId=$noticeId');

      // API 엔드포인트 호출
      final response = await dio.get('/api/v1/artists/notices/$noticeId');

      print('📝 공지사항 상세 응답 상태: ${response.statusCode}');
      print('📝 공지사항 상세 응답 데이터: ${response.data}');

      // API 응답 파싱
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => ArtistNotice.fromJson(data),
      );

      // 성공
      if (apiResponse.status == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        // 에러
        print('📝 공지사항 상세 조회 실패: ${apiResponse.message}');
        throw Failure(
          message: apiResponse.error?.message ?? '공지사항 상세 정보를 불러오는데 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('📝 공지사항 상세 조회 Dio 오류: ${e.message}');
      print('📝 응답 데이터: ${e.response?.data}');
      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('📝 공지사항 상세 조회 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 공지사항 등록 (이미지 포함 가능)
  @override
  Future<void> createArtistNotice(
    String noticeContent, {
    MultipartFile? noticeImage,
  }) async {
    try {
      print('📝 공지사항 등록 요청 시작');
      print('📝 내용: $noticeContent');
      print('📝 이미지 첨부 여부: ${noticeImage != null}');

      // 토큰 직접 가져오기 (인터셉터와 별개로)

      // FormData 준비
      final formData = FormData();
      formData.fields.add(MapEntry('noticeContent', noticeContent));

      if (noticeImage != null) {
        formData.files.add(MapEntry('noticeImage', noticeImage));
      }

      // API 요청 보내기
      final response = await dio.post(
        '/api/v1/artists/notices',
        data: formData,
      );

      print('📝 공지사항 등록 응답 상태: ${response.statusCode}');
      print('📝 공지사항 등록 응답 데이터: ${response.data}');

      // 응답 확인
      if (response.statusCode != 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);
        throw Failure(
          message: apiResponse.error?.message ?? '공지사항 등록에 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      print('📝 공지사항 등록 성공!');
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('📝 공지사항 등록 Dio 오류: ${e.message}');
      print('📝 오류 유형: ${e.type}');
      print('📝 응답 상태 코드: ${e.response?.statusCode}');
      print('📝 응답 데이터: ${e.response?.data}');

      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('📝 공지사항 등록 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}

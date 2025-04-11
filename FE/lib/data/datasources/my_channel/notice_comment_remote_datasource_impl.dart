import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/my_channel/notice_comment_model.dart';
import '../../../domain/usecases/auth/auth_usecase.dart';
import 'notice_comment_remote_datasource.dart';

/// 공지사항 댓글 원격 데이터소스 구현체
/// 서버 API와의 실제 통신을 수행하는 클래스
class NoticeCommentRemoteDataSourceImpl implements NoticeCommentRemoteDataSource {
  final Dio dio;
  final GetTokensUseCase? getTokensUseCase;

  NoticeCommentRemoteDataSourceImpl({
    required this.dio,
    this.getTokensUseCase,
  });

  /// 공지사항의 댓글 목록 조회
  @override
  Future<NoticeCommentsResponse> getNoticeComments(int noticeId) async {
    try {
      print('💬 공지사항 댓글 조회 요청: noticeId=$noticeId');

      // API 엔드포인트 호출
      final response = await dio.get('/api/v1/notices/$noticeId/comments');

      print('💬 댓글 목록 응답 상태: ${response.statusCode}');
      print('💬 댓글 목록 응답 데이터: ${response.data}');

      // API 응답 파싱
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => NoticeCommentsResponse.fromJson(data),
      );

      // 성공
      if (apiResponse.status == 200 && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        // 에러
        print('💬 댓글 목록 조회 실패: ${apiResponse.message}');
        throw Failure(
          message: apiResponse.error?.message ?? '댓글을 불러오는데 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('💬 댓글 목록 조회 Dio 오류: ${e.message}');
      print('💬 응답 데이터: ${e.response?.data}');
      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('💬 댓글 목록 조회 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 새 댓글 등록
  @override
  Future<void> createNoticeComment(int noticeId, String content) async {
    try {
      print('💬 댓글 등록 요청 시작: noticeId=$noticeId');
      print('💬 내용: $content');

      // 요청 본문 준비
      final data = {
        'content': content,
      };

      // API 요청 보내기
      final response = await dio.post(
        '/api/v1/notices/$noticeId/comments',
        data: data,
      );

      print('💬 댓글 등록 응답 상태: ${response.statusCode}');
      print('💬 댓글 등록 응답 데이터: ${response.data}');

      // 응답 확인
      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.status != 200) {
        throw Failure(
          message: apiResponse.error?.message ?? '댓글 등록에 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      print('💬 댓글 등록 성공!');
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('💬 댓글 등록 Dio 오류: ${e.message}');
      print('💬 오류 유형: ${e.type}');
      print('💬 응답 상태 코드: ${e.response?.statusCode}');
      print('💬 응답 데이터: ${e.response?.data}');

      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('💬 댓글 등록 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 댓글 수정
  @override
  Future<void> updateNoticeComment(int noticeId, int commentId, String content) async {
    try {
      print('💬 댓글 수정 요청 시작: noticeId=$noticeId, commentId=$commentId');
      print('💬 새 내용: $content');

      // 요청 본문 준비
      final data = {
        'content': content,
      };

      // API 요청 보내기
      final response = await dio.put(
        '/api/v1/notices/$noticeId/comments/$commentId',
        data: data,
      );

      print('💬 댓글 수정 응답 상태: ${response.statusCode}');
      print('💬 댓글 수정 응답 데이터: ${response.data}');

      // 응답 확인
      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.status != 200) {
        throw Failure(
          message: apiResponse.error?.message ?? '댓글 수정에 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      print('💬 댓글 수정 성공!');
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('💬 댓글 수정 Dio 오류: ${e.message}');
      print('💬 응답 데이터: ${e.response?.data}');

      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('💬 댓글 수정 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 댓글 삭제
  @override
  Future<void> deleteNoticeComment(int noticeId, int commentId) async {
    try {
      print('💬 댓글 삭제 요청 시작: noticeId=$noticeId, commentId=$commentId');

      // API 요청 보내기
      final response = await dio.delete(
        '/api/v1/notices/$noticeId/comments/$commentId',
      );

      print('💬 댓글 삭제 응답 상태: ${response.statusCode}');
      print('💬 댓글 삭제 응답 데이터: ${response.data}');

      // 응답 확인
      final apiResponse = ApiResponse.fromJson(response.data, null);
      
      if (apiResponse.status != 200) {
        throw Failure(
          message: apiResponse.error?.message ?? '댓글 삭제에 실패했습니다.',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      print('💬 댓글 삭제 성공!');
    } on DioException catch (e) {
      // Dio 네트워크 에러 처리
      print('💬 댓글 삭제 Dio 오류: ${e.message}');
      print('💬 응답 데이터: ${e.response?.data}');

      throw Failure(
        message: '네트워크 오류가 발생했습니다: ${e.message}',
        code: e.response?.statusCode.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // 예외 처리
      print('💬 댓글 삭제 기타 오류: $e');
      throw Failure(message: '알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
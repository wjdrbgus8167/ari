// lib/domain/usecases/playback_permission_usecase.dart
import 'package:ari/data/datasources/api_client.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playbackPermissionUsecaseProvider = Provider<PlaybackPermissionUsecase>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider); // 실제 API 클라이언트 사용
  return PlaybackPermissionUsecase(apiClient);
});

class PermissionResult {
  final bool isError;
  final String message;

  PermissionResult.success() : isError = false, message = '';
  PermissionResult.failure(this.message) : isError = true;
}

class PlaybackPermissionUsecase {
  final ApiClient apiClient;

  PlaybackPermissionUsecase(this.apiClient);

  Future<PermissionResult> check(int albumId, int trackId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/albums/$albumId/tracks/$trackId',
      );

      final errorCode = response['error']?['code'];
      if (errorCode == 'S001') {
        return PermissionResult.failure('구독권이 존재하지 않습니다.');
      } else if (errorCode == 'S002') {
        return PermissionResult.failure('해당 트랙은 현재 구독권으로 재생할 수 없습니다.');
      } else if (errorCode == 'S003') {
        return PermissionResult.failure('로그인이 필요합니다.');
      }

      return PermissionResult.success();
    } catch (e) {
      return PermissionResult.failure('재생 권한 확인 중 오류가 발생했습니다.');
    }
  }
}

// 상태 클래스
import 'package:ari/domain/entities/streaming_log.dart';
import 'package:ari/domain/usecases/get_streaming_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamingState {
  final bool isLoading;
  final List<StreamingLog> logs;
  final String? errorMessage;

  StreamingState({
    this.isLoading = false,
    this.logs = const [],
    this.errorMessage,
  });

  StreamingState copyWith({
    bool? isLoading,
    List<StreamingLog>? logs,
    String? errorMessage,
  }) {
    return StreamingState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ViewModel
class StreamingLogViewmodel extends StateNotifier<StreamingState> {
  final GetStreamingLogByTrackId getStreamingLogByTrackId;

  StreamingLogViewmodel({
    required this.getStreamingLogByTrackId,
  }) : super(StreamingState(errorMessage: null)); // 명시적으로 null로 초기화

  // 앨범 상세 정보 로드
  Future<void> loadAlbumDetail(int albumId, int trackId) async {
    // 안전하게 상태 업데이트
    state = StreamingState(
      isLoading: true,
      errorMessage: null,
      logs: state.logs,
    );
    
    final result = await getStreamingLogByTrackId.execute(albumId, trackId);
    
    // Either 결과 처리
    result.fold(
      // 실패 케이스 (Left)
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      // 성공 케이스 (Right)
      (logs) {
        state = state.copyWith(
          isLoading: false,
          logs: logs,
        );
      }
    );
  }
}
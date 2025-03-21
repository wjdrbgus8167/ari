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
  Future<void> loadAlbumDetail(int trackId) async {
    // 안전하게 상태 업데이트
    state = StreamingState(
      isLoading: true,
      errorMessage: null,
      logs: state.logs,
    );
    
    print("왔었니1?");
    // 디버깅 시 안전하게 접근
    print("errorMessage: ${state.errorMessage?.toString() ?? 'null'}");
    
    try {
      final logs = await getStreamingLogByTrackId.execute(trackId);
      
      // 안전하게 상태 업데이트
      state = StreamingState(
        isLoading: false,
        errorMessage: null,
        logs: logs,
      );
      
      print("Error message: ${state.errorMessage?.toString() ?? 'null'}");
      print("종료");
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }
}
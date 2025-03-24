// 상태 클래스
import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/usecases/track_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Track? track;

  TrackDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.track,
  });

  // 상태 복사 메서드
  TrackDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    Track? track,
  }) {
    return TrackDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      track: track ?? this.track,
    );
  }
}

// ViewModel
class TrackDetailViewModel extends StateNotifier<TrackDetailState> {
  final GetTrackDetail getTrackDetail;

  TrackDetailViewModel({
    required this.getTrackDetail,
  }) : super(TrackDetailState(errorMessage: null)); // 명시적으로 null로 초기화
  
  // 트랙 상세 정보 로드
  Future<void> loadTrackDetail(int albumId, int trackId) async {
    // 안전하게 상태 업데이트
    state = TrackDetailState(
      isLoading: true,
      errorMessage: null,
      track: state.track,
    );

    final result = await getTrackDetail.execute(albumId, trackId);
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
      (track) {
        state = state.copyWith(
          isLoading: false,
          track: track,
        );
      }
    );
  }
}
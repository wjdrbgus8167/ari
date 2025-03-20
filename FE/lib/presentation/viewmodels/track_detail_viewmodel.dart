// 상태 클래스
// 상태 클래스
import 'package:ari/data/models/track_detail.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/domain/usecases/track_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackDetailState {
  final bool isLoading;
  final String? errorMessage;
  final TrackDetailModel? track;

  TrackDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.track,
  });

  // 상태 복사 메서드
  TrackDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    TrackDetailModel? track,
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
  Future<void> loadTrackDetail(int trackId) async {
    // 안전하게 상태 업데이트
    state = TrackDetailState(
      isLoading: true,
      errorMessage: null,
      track: state.track,
    );

    // 디버깅 시 안전하게 접근
    print("errorMessage: ${state.errorMessage?.toString() ?? 'null'}");
    try {
      final track = await getTrackDetail.execute(trackId);
      // 안전하게 상태 업데이트
      state = TrackDetailState(
        isLoading: false,
        errorMessage: null,
        track: track,
      );
      print("뷰모델 트랙 확인: " + track.trackTitle);
      print("Error message: ${state.errorMessage?.toString() ?? 'null'}");
    } catch (e) {
      print("Error: ${e.toString()}");
      // 안전하게 상태 업데이트
      state = TrackDetailState(
        isLoading: false,
        errorMessage: e.toString(),
        track: state.track,
      );
    }
  }
}
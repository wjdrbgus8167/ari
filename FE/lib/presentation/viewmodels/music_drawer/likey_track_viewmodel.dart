import 'package:ari/data/models/music_drawer/likey_tracks_model.dart';
import 'package:ari/domain/usecases/music_drawer/likey_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 좋아요 누른 앨범 상태
class LikeyTracksState {
  final List<LikeyTrack> likeyTracks;
  final int likeyTracksCount;
  final bool isLoading;
  final String? errorMessage;

  LikeyTracksState({
    this.likeyTracks = const [],
    this.likeyTracksCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 새로운 상태 생성
  LikeyTracksState copyWith({
    List<LikeyTrack>? likeyTracks,
    int? likeyTracksCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LikeyTracksState(
      likeyTracks: likeyTracks ?? this.likeyTracks,
      likeyTracksCount: likeyTracksCount ?? this.likeyTracksCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 초기 로딩 상태
  factory LikeyTracksState.loading() {
    return LikeyTracksState(isLoading: true);
  }

  /// 에러 상태
  factory LikeyTracksState.error(String message) {
    return LikeyTracksState(errorMessage: message);
  }
}

/// 구독 중인 아티스트 뷰모델
class LikeyTrackViewmodel extends StateNotifier<LikeyTracksState> {
  final GetLikeyTracksUseCase _getLikeyTracksUseCase;
  
  LikeyTrackViewmodel(
    this._getLikeyTracksUseCase,
  ) : super(LikeyTracksState()) {
    // 초기 데이터 로드
    loadLikeyTracks();
  }

  /// 구독 중인 아티스트 목록 로드
  Future<void> loadLikeyTracks() async {
    try {
      state = LikeyTracksState.loading();

      final result = await _getLikeyTracksUseCase();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            likeyTracks: [],
          );
        },
        (result) {
          state = state.copyWith(likeyTracks: result.tracks, likeyTracksCount: result.trackCount, isLoading: false);
        },
      );
    } catch (e) {
      state = LikeyTracksState.error(e.toString());
    }
  }
}

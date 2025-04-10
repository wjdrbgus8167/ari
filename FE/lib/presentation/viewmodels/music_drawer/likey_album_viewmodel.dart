
import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/domain/usecases/music_drawer/likey_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 좋아요 누른 앨범 상태
class LikeyAlbumsState {
  final List<LikeyAlbum> likeyAlbums;
  final int likeyAlbumsCount;
  final bool isLoading;
  final String? errorMessage;

  LikeyAlbumsState({
    this.likeyAlbums = const [],
    this.likeyAlbumsCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 새로운 상태 생성
  LikeyAlbumsState copyWith({
    List<LikeyAlbum>? likeyAlbums,
    int? likeyAlbumsCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LikeyAlbumsState(
      likeyAlbums: likeyAlbums ?? this.likeyAlbums,
      likeyAlbumsCount: likeyAlbumsCount ?? this.likeyAlbumsCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 초기 로딩 상태
  factory LikeyAlbumsState.loading() {
    return LikeyAlbumsState(isLoading: true);
  }

  /// 에러 상태
  factory LikeyAlbumsState.error(String message) {
    return LikeyAlbumsState(errorMessage: message);
  }
}

/// 구독 중인 아티스트 뷰모델
class LikeyAlbumViewmodel extends StateNotifier<LikeyAlbumsState> {
  final GetLikeyAlbumsUseCase _getLikeyAlbumsUseCase;
  
  LikeyAlbumViewmodel(
    this._getLikeyAlbumsUseCase,
  ) : super(LikeyAlbumsState()) {
    // 초기 데이터 로드
    loadLikeyAlbums();
  }

  /// 구독 중인 아티스트 목록 로드
  Future<void> loadLikeyAlbums() async {
    try {
      state = LikeyAlbumsState.loading();

      final result = await _getLikeyAlbumsUseCase();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            likeyAlbums: [],
          );
        },
        (result) {
          state = state.copyWith(likeyAlbums: result.albums, likeyAlbumsCount: result.albumCount, isLoading: false);
        },
      );
    } catch (e) {
      state = LikeyAlbumsState.error(e.toString());
    }
  }
}

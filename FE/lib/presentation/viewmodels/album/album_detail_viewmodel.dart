import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 상태 클래스
class AlbumDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Album? album;

  AlbumDetailState({this.isLoading = false, this.errorMessage, this.album});

  // 상태 복사 메서드
  AlbumDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    Album? album,
  }) {
    return AlbumDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      album: album ?? this.album,
    );
  }
}

// ViewModel
class AlbumDetailViewModel extends StateNotifier<AlbumDetailState> {
  final GetAlbumDetail getAlbumDetail;
  final RateAlbum rateAlbumUseCase;

  AlbumDetailViewModel({
    required this.getAlbumDetail,
    required this.rateAlbumUseCase,
  }) : super(AlbumDetailState(errorMessage: null));

  Future<void> loadAlbumDetail(int albumId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAlbumDetail.execute(albumId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (album) {
        state = state.copyWith(isLoading: false, album: album);
      },
    );
  }

  /// ⭐️ 올바르게 수정된 평점 제출 메서드
  Future<bool> submitRating(int albumId, double rating) async {
    final result = await rateAlbumUseCase.execute(albumId, rating); // ✅ 인스턴스 사용
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) => true);
  }
}

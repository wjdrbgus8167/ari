import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/domain/usecases/album_like_usecase.dart';
import 'package:ari/domain/entities/album.dart';

/// 상태 클래스
class AlbumDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Album? album;

  AlbumDetailState({this.isLoading = false, this.errorMessage, this.album});

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

/// ViewModel 클래스
class AlbumDetailViewModel extends StateNotifier<AlbumDetailState> {
  final GetAlbumDetail getAlbumDetail;
  final RateAlbum rateAlbumUseCase;
  final ToggleAlbumLike toggleAlbumLikeUseCase; // 추가: 좋아요 UseCase 필드
  final Ref ref;

  AlbumDetailViewModel({
    required this.getAlbumDetail,
    required this.rateAlbumUseCase,
    required this.toggleAlbumLikeUseCase, // 생성자에 추가
    required this.ref,
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

  Future<bool> submitRating(int albumId, double rating) async {
    final result = await rateAlbumUseCase.execute(albumId, rating);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // ✅ 별점을 double → string 변환해 업데이트
        final updatedAlbum = state.album?.copyWith(
          rating: rating.toStringAsFixed(1),
        );
        state = state.copyWith(album: updatedAlbum);
        return true;
      },
    );
  }

  Future<void> toggleLike(int albumId, bool currentStatus) async {
    try {
      // 현재 상태가 null일 수 있으므로, album의 좋아요 상태가 null이면 기본값 false로 간주합니다.
      final currentLiked = state.album?.albumLikedYn ?? false;
      final success = await toggleAlbumLikeUseCase.execute(
        albumId,
        currentLiked,
      );
      if (success) {
        // 업데이트 시, 기존 값이 null인 경우에도 false로 처리되어 토글됩니다.
        final updatedAlbum = state.album?.copyWith(albumLikedYn: !currentLiked);
        state = state.copyWith(album: updatedAlbum);
      }
    } catch (error) {
      state = state.copyWith(errorMessage: '좋아요 처리에 실패했습니다: $error');
    }
  }
}

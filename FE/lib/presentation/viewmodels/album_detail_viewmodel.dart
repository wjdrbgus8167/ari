// presentation/viewmodels/album_detail_viewmodel.dart
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 상태 클래스
class AlbumDetailState {
  final bool isLoading;
  final String? errorMessage;
  final AlbumDetail? albumDetail;

  AlbumDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.albumDetail,
  });

  // 상태 복사 메서드
  AlbumDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    AlbumDetail? albumDetail,
  }) {
    return AlbumDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      albumDetail: albumDetail ?? this.albumDetail,
    );
  }
}

// ViewModel
class AlbumDetailViewModel extends StateNotifier<AlbumDetailState> {
  final GetAlbumDetail getAlbumDetail;

  AlbumDetailViewModel({
    required this.getAlbumDetail,
  }) : super(AlbumDetailState());

  // 앨범 상세 정보 로드
  // 앨범 상세 정보 로드
  Future<void> loadAlbumDetail(int albumId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final albumDetail = await getAlbumDetail.execute(albumId);
      state = state.copyWith(
        isLoading: false,
        albumDetail: albumDetail,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
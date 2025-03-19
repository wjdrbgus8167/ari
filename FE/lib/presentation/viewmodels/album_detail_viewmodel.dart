// presentation/viewmodels/album_detail_viewmodel.dart
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 상태 클래스
class AlbumDetailState {
  final bool isLoading;
  final String? errorMessage;
  final Album? album;

  AlbumDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.album,
  });

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

  AlbumDetailViewModel({
    required this.getAlbumDetail,
  }) : super(AlbumDetailState(errorMessage: null)); // 명시적으로 null로 초기화

  // 앨범 상세 정보 로드
  Future<void> loadAlbumDetail(int albumId) async {
    // 안전하게 상태 업데이트
    state = AlbumDetailState(
      isLoading: true,
      errorMessage: null,
      album: state.album,
    );
    
    print("왔었니1?");
    // 디버깅 시 안전하게 접근
    print("errorMessage: ${state.errorMessage?.toString() ?? 'null'}");
    
    try {
      final album = await getAlbumDetail.execute(albumId);
      print(album.id);
      
      // 안전하게 상태 업데이트
      state = AlbumDetailState(
        isLoading: false,
        errorMessage: null,
        album: album,
      );
      
      print("Album comments: ${state.album?.comments}");
      print("Error message: ${state.errorMessage?.toString() ?? 'null'}");
      print("종료");
    } catch (e) {
      print("Error: ${e.toString()}");
      
      // 안전하게 상태 업데이트
      state = AlbumDetailState(
        isLoading: false,
        errorMessage: e.toString(),
        album: state.album,
      );
    }
  }
}
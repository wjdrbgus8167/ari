import 'package:ari/data/models/music_drawer/likey_albums_model.dart';
import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/usecases/album_detail_usecase.dart';
import 'package:ari/domain/usecases/music_drawer/likey_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 좋아요 누른 앨범 상태 수정
class LikeyAlbumsState {
  final List<LikeyAlbum> likeyAlbums;
  final Map<int, Album> albumDetails; // 앨범 ID -> 상세 정보 맵
  final int likeyAlbumsCount;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded; // 데이터 로드 시도 여부 추적

  LikeyAlbumsState({
    this.likeyAlbums = const [],
    this.albumDetails = const {},
    this.likeyAlbumsCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false, // 초기값은 false
  });

  /// 새로운 상태 생성
  LikeyAlbumsState copyWith({
    List<LikeyAlbum>? likeyAlbums,
    Map<int, Album>? albumDetails,
    int? likeyAlbumsCount,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return LikeyAlbumsState(
      likeyAlbums: likeyAlbums ?? this.likeyAlbums,
      albumDetails: albumDetails ?? this.albumDetails,
      likeyAlbumsCount: likeyAlbumsCount ?? this.likeyAlbumsCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }

  /// 초기 로딩 상태
  factory LikeyAlbumsState.loading() {
    return LikeyAlbumsState(isLoading: true);
  }

  /// 에러 상태
  factory LikeyAlbumsState.error(String message) {
    return LikeyAlbumsState(errorMessage: message, hasLoaded: true);
  }
}

/// 구독 중인 아티스트 뷰모델 수정
class LikeyAlbumViewmodel extends StateNotifier<LikeyAlbumsState> {
  final GetLikeyAlbumsUseCase _getLikeyAlbumsUseCase;
  final GetAlbumDetail _getAlbumDetail;
  
  LikeyAlbumViewmodel(
    this._getLikeyAlbumsUseCase,
    this._getAlbumDetail,
  ) : super(LikeyAlbumsState()) {
    // 초기 데이터 로드는 UI에서 필요할 때 호출하도록 변경
    // loadLikeyAlbums();
  }

  /// 구독 중인 아티스트 목록 로드
  Future<void> loadLikeyAlbums() async {
    // 이미 로딩 중이거나 로드된 경우 중복 호출 방지
    if (state.isLoading || state.hasLoaded) {
      return;
    }
    
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _getLikeyAlbumsUseCase();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            likeyAlbums: [],
            hasLoaded: true, // 로드 시도 완료
          );
        },
        (result) {
          state = state.copyWith(
            likeyAlbums: result.albums, 
            likeyAlbumsCount: result.albumCount, 
            isLoading: false,
            hasLoaded: true // 로드 완료
          );
          
          // 좋아요 누른 앨범들의 상세 정보 로드
          _loadAllAlbumDetails();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString(),
        hasLoaded: true // 오류가 있어도 로드 시도는 완료
      );
    }
  }

  /// 특정 앨범의 상세 정보 로드
  Future<void> loadAlbumDetail(int albumId) async {
    if (state.albumDetails.containsKey(albumId)) {
      // 이미 로드된 앨범 상세 정보가 있으면 다시 로드하지 않음
      return;
    }
    
    try {
      final result = await _getAlbumDetail.execute(albumId);
      result.fold(
        (failure) {
          // 개별 앨범 로드 실패해도 전체 상태를 에러로 만들지 않음
        },
        (album) {
          // 기존 앨범 상세 정보 맵에 새 앨범 정보 추가
          final updatedAlbumDetails = Map<int, Album>.from(state.albumDetails);
          updatedAlbumDetails[albumId] = album;
          
          state = state.copyWith(albumDetails: updatedAlbumDetails);
        },
      );
    } catch (e) {
      // 개별 앨범 로드 오류 처리
    }
  }

  /// 모든 좋아요 앨범의 상세 정보 로드
  Future<void> _loadAllAlbumDetails() async {
    // 모든 앨범에 대해 병렬로 상세 정보 로드
    final futures = state.likeyAlbums.map((album) => loadAlbumDetail(album.albumId));
    await Future.wait(futures);
  }

  /// 특정 앨범 상세 정보 가져오기 (UI에서 사용)
  Album? getAlbumDetail(int albumId) {
    return state.albumDetails[albumId];
  }
  
  /// 모든 앨범 상세 정보 다시 로드
  Future<void> refreshAllAlbumDetails() async {
    final updatedAlbumDetails = <int, Album>{};
    state = state.copyWith(albumDetails: updatedAlbumDetails);
    await _loadAllAlbumDetails();
  }
  
  /// 데이터 강제 새로고침 (UI에서 명시적으로 호출)
  Future<void> refresh() async {
    state = state.copyWith(hasLoaded: false);
    await loadLikeyAlbums();
  }
}
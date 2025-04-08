// 아티스트 구독 상태 클래스
import 'package:ari/data/models/subscription/artist_subscription_models.dart';
import 'package:ari/domain/usecases/subscription/subscription_history_usecase.dart';
import 'package:ari/presentation/viewmodels/subscription/my_subscription_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistSubscriptionState {
  final bool isLoading;
  final String? errorMessage;
  final List<Artist> artists;
  final Artist? selectedArtist;
  final ArtistDetail? artistDetail;
  
  ArtistSubscriptionState({
    this.isLoading = false,
    this.errorMessage,
    this.artists = const [],
    this.selectedArtist,
    this.artistDetail,
  });
  
  // 복사본 생성
  ArtistSubscriptionState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Artist>? artists,
    Artist? selectedArtist,
    ArtistDetail? artistDetail,
  }) {
    return ArtistSubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      artists: artists ?? this.artists,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      artistDetail: artistDetail ?? this.artistDetail,
    );
  }
}

// ViewModel 클래스
class ArtistSubscriptionViewModel extends StateNotifier<ArtistSubscriptionState> {
  final ArtistSubscriptionHistoryUsecase _historyUsecase;
  final ArtistSubscriptionDetailUsecase _detailUsecase;
  
  ArtistSubscriptionViewModel(this._historyUsecase, this._detailUsecase) 
      : super(ArtistSubscriptionState());
  
  // 아티스트 목록 로드
  Future<void> loadArtistList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _historyUsecase();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '아티스트 목록을 불러오는 중 오류가 발생했습니다: ${failure.message}',
        );
      },
      (artistsResponse) {
        if (artistsResponse.artists.isNotEmpty) {
          state = state.copyWith(
            isLoading: false,
            artists: artistsResponse.artists,
            selectedArtist: artistsResponse.artists.first, // 기본적으로 첫 번째 아티스트 선택
          );
          
          // 선택된 아티스트에 대한 상세 정보 로드
          //loadArtistDetail(artistsResponse.artists.first.artistId);
        } else {
          state = state.copyWith(
            isLoading: false,
            artists: artistsResponse.artists,
          );
        }
      }
    );
  }
  
  // 특정 아티스트에 대한 상세 정보 로드
  Future<void> loadArtistDetail(int artistId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _detailUsecase(artistId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '아티스트 상세 정보를 불러오는 중 오류가 발생했습니다: ${failure.message}',
        );
      },
      (detail) {
        // 해당 아티스트 객체 찾기
        final selectedArtist = state.artists.firstWhere(
          (artist) => artist.artistId == artistId,
          orElse: () => state.selectedArtist!,
        );
        
        state = state.copyWith(
          isLoading: false,
          selectedArtist: selectedArtist,
          artistDetail: detail,
        );
      }
    );
  }
  
  // 아티스트 변경 처리
  void selectArtist(Artist artist) {
    if (state.selectedArtist?.artistId != artist.artistId) {
      if (artist.artistId != null) {
        loadArtistDetail(artist.artistId!);  
      }
    }
  }
}

// Provider 정의
final artistSubscriptionViewModelProvider =
    StateNotifierProvider<ArtistSubscriptionViewModel, ArtistSubscriptionState>((ref) {
  final historyUsecase = ref.watch(artistSubscriptionHistoryUsecaseProvider);
  final detailUsecase = ref.watch(artistSubscriptionDetailUsecaseProvider);
  return ArtistSubscriptionViewModel(historyUsecase, detailUsecase);
});

// UseCase Provider 정의
final artistSubscriptionHistoryUsecaseProvider = Provider<ArtistSubscriptionHistoryUsecase>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return ArtistSubscriptionHistoryUsecase(repository);
});

final artistSubscriptionDetailUsecaseProvider = Provider<ArtistSubscriptionDetailUsecase>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return ArtistSubscriptionDetailUsecase(repository);
});
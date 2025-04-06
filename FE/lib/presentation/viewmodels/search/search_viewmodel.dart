import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/search_response.dart';
import 'package:ari/domain/usecases/search_usecase.dart';

/// 검색 화면 상태
class SearchState {
  final bool isLoading;
  final String query;
  final List<ArtistSearchResult> artists;
  final List<TrackSearchResult> tracks;
  final String? errorMessage;

  /// [isLoading] 로딩 중 여부
  /// [query] 검색어
  /// [artists] 검색된 아티스트 목록
  /// [tracks] 검색된 트랙 목록
  /// [errorMessage] 오류 메시지
  SearchState({
    this.isLoading = false,
    this.query = '',
    this.artists = const [],
    this.tracks = const [],
    this.errorMessage,
  });

  /// 초기 상태
  factory SearchState.initial() => SearchState();

  /// 로딩 상태로 변경
  SearchState copyWithLoading() {
    return SearchState(
      isLoading: true,
      query: query,
      artists: artists,
      tracks: tracks,
    );
  }

  /// 상태 복사
  SearchState copyWith({
    bool? isLoading,
    String? query,
    List<ArtistSearchResult>? artists,
    List<TrackSearchResult>? tracks,
    String? errorMessage,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      artists: artists ?? this.artists,
      tracks: tracks ?? this.tracks,
      errorMessage: errorMessage,
    );
  }
}

/// 검색 화면 ViewModel: 검색 기능, 상태 관리
class SearchViewModel extends StateNotifier<SearchState> {
  final SearchUseCase _searchUseCase;

  SearchViewModel({required SearchUseCase searchUseCase})
    : _searchUseCase = searchUseCase,
      super(SearchState.initial());

  /// 검색어로 검색 수행
  Future<void> search(String query) async {
    // 검색어가 비어있는 경우 초기 상태로 변경
    if (query.trim().isEmpty) {
      state = state.copyWith(
        query: '',
        artists: [],
        tracks: [],
        isLoading: false,
        errorMessage: null,
      );
      return;
    }

    // 로딩 상태로 변경
    state = state.copyWithLoading();

    try {
      // 검색 수행
      final result = await _searchUseCase.execute(query);

      // 검색 결과로 상태 업데이트
      state = state.copyWith(
        isLoading: false,
        query: query,
        artists: result.artists,
        tracks: result.tracks,
        errorMessage: null,
      );
    } catch (e) {
      // 오류 발생 시 상태 업데이트
      state = state.copyWith(
        isLoading: false,
        errorMessage: '검색 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 검색 상태 초기화
  void clearSearch() {
    state = SearchState.initial();
  }
}

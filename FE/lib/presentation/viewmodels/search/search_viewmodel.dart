import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/models/search_response.dart';
import 'package:ari/domain/usecases/search_usecase.dart';
import 'dart:async'; // 타이머

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

  // 디바운스 타이머
  Timer? _debounceTimer;

  SearchViewModel({required SearchUseCase searchUseCase})
    : _searchUseCase = searchUseCase,
      super(SearchState.initial());

  /// 검색어로 검색 수행 (디바운스 적용)
  /// 실시간 검색의 빈번한 API 호출 방지
  Future<void> search(String query) async {
    // 검색어 변경되면 이전 타이머 취소
    _debounceTimer?.cancel();

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

    // 쿼리 변경 즉시 로딩 상태로 변경하고 쿼리 업데이트
    state = state.copyWith(isLoading: true, query: query, errorMessage: null);

    // 500ms 디바운스
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        print('검색 실행: $query'); // 로깅 추가

        // 검색 수행
        final result = await _searchUseCase.execute(query);

        // 현재 검색어와 함수 호출 시 검색어가 다르면 무시
        // 검색을 계속 요청하면 이전 요청의 결과가 늦게 도착해 UI가 꼬이는 거 방지
        if (state.query != query) {
          print('검색 결과 무시: 검색어 변경됨 ($query -> ${state.query})');
          return;
        }

        print(
          '검색 결과: 아티스트 ${result.artists.length}개, 트랙 ${result.tracks.length}개',
        );

        // 검색 결과로 상태 업데이트
        state = state.copyWith(
          isLoading: false,
          artists: result.artists,
          tracks: result.tracks,
          errorMessage: null,
        );
      } catch (e) {
        print('검색 오류: $e');

        // 오류 발생 시 상태 업데이트
        state = state.copyWith(
          isLoading: false,
          errorMessage: '검색 중 오류가 발생했습니다: ${e.toString()}',
        );
      }
    });
  }

  /// 검색 상태 초기화
  void clearSearch() {
    _debounceTimer?.cancel(); // 타이머 취소
    state = SearchState.initial();
  }

  // 타이머 해제
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/data/models/album.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/domain/entities/chart_item.dart';
import 'package:ari/domain/usecases/genre/get_genre_data_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

/// 차트 기간 타입 (주간/월간)
enum ChartPeriodType {
  weekly, // 주간 (7일)
  monthly, // 월간 (30일)
}

/// 장르별 페이지 상태
class GenreState {
  final bool isLoading;
  final Genre genre;
  final String genreName;
  final List<Album> newAlbums;
  final List<Album> popularAlbums;
  final List<ChartItem> monthlyCharts; // 월간 차트 (30일)
  final List<Track> weeklyTracks; // 주간 인기 트랙 (7일)
  final ChartPeriodType selectedChartType;
  final String? errorMessage;

  GenreState({
    required this.isLoading,
    required this.genre,
    required this.genreName,
    required this.newAlbums,
    required this.popularAlbums,
    required this.monthlyCharts,
    required this.weeklyTracks,
    required this.selectedChartType,
    this.errorMessage,
  });

  factory GenreState.initial(Genre genre) {
    return GenreState(
      isLoading: true,
      genre: genre,
      genreName: genre.displayName,
      newAlbums: [],
      popularAlbums: [],
      monthlyCharts: [],
      weeklyTracks: [],
      selectedChartType: ChartPeriodType.monthly,
      errorMessage: null,
    );
  }

  /// 현재 선택된 차트 항목
  List<dynamic> get currentChartItems {
    if (selectedChartType == ChartPeriodType.monthly) {
      return monthlyCharts;
    } else {
      return weeklyTracks;
    }
  }

  /// 상태 복사 메서드
  GenreState copyWith({
    bool? isLoading,
    Genre? genre,
    String? genreName,
    List<Album>? newAlbums,
    List<Album>? popularAlbums,
    List<ChartItem>? monthlyCharts,
    List<Track>? weeklyTracks,
    ChartPeriodType? selectedChartType,
    String? errorMessage,
  }) {
    return GenreState(
      isLoading: isLoading ?? this.isLoading,
      genre: genre ?? this.genre,
      genreName: genreName ?? this.genreName,
      newAlbums: newAlbums ?? this.newAlbums,
      popularAlbums: popularAlbums ?? this.popularAlbums,
      monthlyCharts: monthlyCharts ?? this.monthlyCharts,
      weeklyTracks: weeklyTracks ?? this.weeklyTracks,
      selectedChartType: selectedChartType ?? this.selectedChartType,
      errorMessage: errorMessage,
    );
  }
}

/// 장르별 페이지 뷰모델
class GenreViewModel extends StateNotifier<GenreState> {
  final GetGenreDataUseCase _genreDataUseCase;

  GenreViewModel({
    required GetGenreDataUseCase genreDataUseCase,
    required Genre genre,
  }) : _genreDataUseCase = genreDataUseCase,
        super(GenreState.initial(genre)) {
    // 초기 데이터 로드
    loadGenreData();
  }

  /// 장르 데이터 로드
  Future<void> loadGenreData() async {
    try {
      // 장르 ID 대신 Genre enum을 직접 전달
      final results = await Future.wait([
        _genreDataUseCase.getGenreNewAlbums(state.genre),
        _genreDataUseCase.getGenrePopularAlbums(state.genre),
        _genreDataUseCase.getGenreCharts(state.genre),
        _genreDataUseCase.getGenrePopularTracks(state.genre),
      ]);

      // 결과 처리
      final newAlbumsResult = results[0] as Either<Failure, List<Album>>;
      final popularAlbumsResult = results[1] as Either<Failure, List<Album>>;
      final monthlyChartsResult =
          results[2] as Either<Failure, List<ChartItem>>;
      final weeklyTracksResult = results[3] as Either<Failure, List<Track>>;
      // 새 상태 구성
      newAlbumsResult.fold((failure) => _handleError(failure.message), (
        newAlbums,
      ) {
        popularAlbumsResult.fold((failure) => _handleError(failure.message), (
          popularAlbums,
        ) {
          monthlyChartsResult.fold((failure) => _handleError(failure.message), (
            monthlyCharts,
          ) {
            weeklyTracksResult.fold(
              (failure) => _handleError(failure.message),
              (weeklyTracks) {
                // 모든 데이터가 성공적으로 로드된 경우
                state = state.copyWith(
                  isLoading: false,
                  newAlbums: newAlbums,
                  popularAlbums: popularAlbums,
                  monthlyCharts: monthlyCharts,
                  weeklyTracks: weeklyTracks,
                  errorMessage: null,
                );
              },
            );
          });
        });
      });
    } catch (e) {
      _handleError('데이터 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// 오류 처리
  void _handleError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }

  /// 차트 기간 타입 변경 (주간/월간)
  void toggleChartPeriodType() {
    final newType =
        state.selectedChartType == ChartPeriodType.monthly
            ? ChartPeriodType.weekly
            : ChartPeriodType.monthly;

    state = state.copyWith(selectedChartType: newType);
  }

  /// 특정 차트 기간 타입 선택
  void selectChartPeriodType(ChartPeriodType type) {
    if (state.selectedChartType != type) {
      state = state.copyWith(selectedChartType: type);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await loadGenreData();
  }
}

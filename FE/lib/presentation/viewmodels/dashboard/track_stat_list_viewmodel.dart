import 'package:ari/data/datasources/dashboard/dashboard_datasources.dart';
import 'package:ari/data/models/dashboard/track_stats_model.dart';
import 'package:ari/data/repositories/dashboard/dashboard_repository.dart';
import 'package:ari/domain/repositories/dashboard/dashboard_repository.dart';
import 'package:ari/domain/usecases/dashboard/my_track_list_usecase.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortBy {
  totalStreamingCount,
  monthlyStreamingCount,
}

class TrackListState {
  final List<TrackStats> tracks;
  final SortBy sortBy;
  final bool isLoading;
  final String? errorMessage;

  TrackListState({
    this.tracks = const [],
    this.sortBy = SortBy.totalStreamingCount,
    this.isLoading = false,
    this.errorMessage,
  });

  TrackListState copyWith({
    List<TrackStats>? tracks,
    SortBy? sortBy,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrackListState(
      tracks: tracks ?? this.tracks,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TrackStatsListViewmodel extends StateNotifier<TrackListState> {
  final GetTrackStatsUseCase useCase;

  TrackStatsListViewmodel(this.useCase) : super(TrackListState()) {
    loadTrackStats();
  }

  Future<void> loadTrackStats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await useCase();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (trackStatsList) {
        final sortedTracks = _sortTracks(trackStatsList.tracks, state.sortBy);
        state = state.copyWith(
          tracks: sortedTracks,
          isLoading: false,
        );
      },
    );
  }

  void changeSortBy() {
    final newSortBy = state.sortBy == SortBy.totalStreamingCount 
        ? SortBy.monthlyStreamingCount 
        : SortBy.totalStreamingCount;
    
    final sortedTracks = _sortTracks(state.tracks, newSortBy);
    
    state = state.copyWith(
      sortBy: newSortBy,
      tracks: sortedTracks,
    );
  }

  List<TrackStats> _sortTracks(List<TrackStats> tracks, SortBy sortBy) {
    final sortedTracks = List<TrackStats>.from(tracks);
    
    if (sortBy == SortBy.totalStreamingCount) {
      sortedTracks.sort((a, b) => b.totalStreamingCount.compareTo(a.totalStreamingCount));
    } else {
      sortedTracks.sort((a, b) => b.monthlyStreamingCount.compareTo(a.monthlyStreamingCount));
    }
    
    return sortedTracks;
  }
}

final dashboardDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSourceImpl(apiClient: apiClient);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(dashboardDataSourceProvider);
  return DashboardRepositoryImpl(dataSource: dataSource);
});

final dashboardUseCaseProvider = Provider<GetTrackStatsUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetTrackStatsUseCase(repository);
});

final trackListProvider = StateNotifierProvider<TrackStatsListViewmodel, TrackListState>((ref) {
  final useCase = ref.watch(dashboardUseCaseProvider);
  return TrackStatsListViewmodel(useCase);
});
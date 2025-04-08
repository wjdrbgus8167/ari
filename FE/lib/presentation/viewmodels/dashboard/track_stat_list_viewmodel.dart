import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackStat {
  final int id;
  final String title;
  final String imageUrl;
  final int monthlyPlayCount;
  final int totalPlayCount;

  TrackStat({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.monthlyPlayCount,
    required this.totalPlayCount,
  });
}

// 정렬 기준
enum SortBy { totalPlayCount, monthlyPlayCount }

// ViewModel 상태 클래스
class TrackListState {
  final List<TrackStat> tracks;
  final SortBy sortBy;
  final bool isLoading;

  TrackListState({
    this.tracks = const [],
    this.sortBy = SortBy.totalPlayCount,
    this.isLoading = false,
  });

  TrackListState copyWith({
    List<TrackStat>? tracks,
    SortBy? sortBy,
    bool? isLoading,
  }) {
    return TrackListState(
      tracks: tracks ?? this.tracks,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TrackListNotifier extends StateNotifier<TrackListState> {
  TrackListNotifier() : super(TrackListState()) {
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    state = state.copyWith(isLoading: true);

    // 데이터 로드 (실제로는 API 호출 등)
    await Future.delayed(const Duration(milliseconds: 500)); // 임시 지연

    // 샘플 데이터
    final tracks = [
      TrackStat(
        id: 1,
        title: 'AFTER HOURS',
        imageUrl: 'https://placehold.co/45x45',
        monthlyPlayCount: 1234,
        totalPlayCount: 123456,
      ),
      TrackStat(
        id: 2,
        title: 'AFTER HOURS',
        imageUrl: 'https://placehold.co/45x45',
        monthlyPlayCount: 5678,
        totalPlayCount: 98765,
      ),
      TrackStat(
        id: 3,
        title: 'AFTER HOURS',
        imageUrl: 'https://placehold.co/45x45',
        monthlyPlayCount: 9012,
        totalPlayCount: 78901,
      ),
    ];

    // 현재 정렬 기준에 따라 정렬
    final sortedTracks = _sortTracks(tracks, state.sortBy);

    state = state.copyWith(tracks: sortedTracks, isLoading: false);
  }

  // 정렬 기준 변경
  void changeSortBy() {
    final newSortBy =
        state.sortBy == SortBy.totalPlayCount
            ? SortBy.monthlyPlayCount
            : SortBy.totalPlayCount;

    final sortedTracks = _sortTracks(state.tracks, newSortBy);

    state = state.copyWith(sortBy: newSortBy, tracks: sortedTracks);
  }

  // 트랙 정렬
  List<TrackStat> _sortTracks(List<TrackStat> tracks, SortBy sortBy) {
    final sortedTracks = List<TrackStat>.from(tracks);

    if (sortBy == SortBy.totalPlayCount) {
      sortedTracks.sort((a, b) => b.totalPlayCount.compareTo(a.totalPlayCount));
    } else {
      sortedTracks.sort(
        (a, b) => b.monthlyPlayCount.compareTo(a.monthlyPlayCount),
      );
    }

    return sortedTracks;
  }
}

final trackListProvider =
    StateNotifierProvider<TrackListNotifier, TrackListState>((ref) {
      return TrackListNotifier();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dummy_data/mock_data.dart';
import '../../../data/models/track.dart';

class ListeningQueueState {
  final List<Track> playlist;
  final List<Track> filteredPlaylist;
  final Set<Track> selectedTracks;

  ListeningQueueState({
    required this.playlist,
    required this.filteredPlaylist,
    required this.selectedTracks,
  });

  ListeningQueueState copyWith({
    List<Track>? playlist,
    List<Track>? filteredPlaylist,
    Set<Track>? selectedTracks,
  }) {
    return ListeningQueueState(
      playlist: playlist ?? this.playlist,
      filteredPlaylist: filteredPlaylist ?? this.filteredPlaylist,
      selectedTracks: selectedTracks ?? this.selectedTracks,
    );
  }
}

class ListeningQueueViewModel extends StateNotifier<ListeningQueueState> {
  ListeningQueueViewModel()
    : super(
        ListeningQueueState(
          playlist: MockData.getListeningQueue(),
          filteredPlaylist: MockData.getListeningQueue(),
          selectedTracks: {},
        ),
      );

  void filterTracks(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredPlaylist: List.from(state.playlist));
    } else {
      final filtered =
          state.playlist.where((track) {
            return track.trackTitle.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                track.artist.toLowerCase().contains(query.toLowerCase());
          }).toList();
      state = state.copyWith(filteredPlaylist: filtered);
    }
  }

  void toggleTrackSelection(Track track) {
    final newSelected = Set<Track>.from(state.selectedTracks);
    if (newSelected.contains(track)) {
      newSelected.remove(track);
    } else {
      newSelected.add(track);
    }
    state = state.copyWith(selectedTracks: newSelected);
  }

  void toggleSelectAll() {
    final allSelected =
        state.filteredPlaylist.isNotEmpty &&
        state.selectedTracks.length == state.filteredPlaylist.length;
    if (allSelected) {
      state = state.copyWith(selectedTracks: {});
    } else {
      state = state.copyWith(selectedTracks: Set.from(state.filteredPlaylist));
    }
  }

  void reorderTracks(int oldIndex, int newIndex) {
    final updatedList = List<Track>.from(state.filteredPlaylist);
    if (newIndex > oldIndex) newIndex -= 1;
    final track = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, track);
    state = state.copyWith(filteredPlaylist: updatedList);
    // 원본 playlist도 재정렬할 필요가 있다면 업데이트
  }

  void removeTrack(Track track) {
    // 기존 플레이리스트에서 해당 트랙 삭제
    final newPlaylist = List<Track>.from(state.playlist)..remove(track);
    // 필터링된 플레이리스트에서도 삭제
    final newFilteredPlaylist = List<Track>.from(state.filteredPlaylist)
      ..remove(track);
    // 선택된 트랙에서도 삭제
    final newSelectedTracks = Set<Track>.from(state.selectedTracks)
      ..remove(track);

    state = state.copyWith(
      playlist: newPlaylist,
      filteredPlaylist: newFilteredPlaylist,
      selectedTracks: newSelectedTracks,
    );
  }
}

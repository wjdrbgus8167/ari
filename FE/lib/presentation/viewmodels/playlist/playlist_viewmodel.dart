import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'playlist_state.dart';

class PlaylistViewModel extends StateNotifier<PlaylistState> {
  PlaylistViewModel() : super(PlaylistState(selectedTracks: {}));

  void setPlaylist(Playlist playlist) {
    state = state.copyWith(selectedPlaylist: playlist, selectedTracks: {});
  }

  void toggleTrackSelection(PlaylistTrackItem item) {
    final newSelected = Set<PlaylistTrackItem>.from(state.selectedTracks);
    if (newSelected.contains(item)) {
      newSelected.remove(item);
    } else {
      newSelected.add(item);
    }
    state = state.copyWith(selectedTracks: newSelected);
  }

  void selectAllTracks() {
    if (state.selectedPlaylist != null) {
      state = state.copyWith(
        selectedTracks: Set.from(state.selectedPlaylist!.tracks),
      );
    }
  }

  void searchTracks(String query) {
    if (state.selectedPlaylist == null) {
      return;
    }

    final allTracks = state.selectedPlaylist!.tracks;

    final filtered =
        allTracks.where((item) {
          final title = item.track.trackTitle.toLowerCase();
          final artist = item.track.artistName.toLowerCase();
          return title.contains(query.toLowerCase()) ||
              artist.contains(query.toLowerCase());
        }).toList();

    state = state.copyWith(filteredTracks: filtered);
  }

  void deselectAllTracks() {
    state = state.copyWith(selectedTracks: {});
  }

  void toggleSelectAll() {
    if (state.selectedPlaylist == null) return;
    final allSelected = state.selectedPlaylist!.tracks.every(
      (item) => state.selectedTracks.contains(item),
    );
    if (allSelected) {
      deselectAllTracks();
    } else {
      selectAllTracks();
    }
  }

  void reorderTracks(int oldIndex, int newIndex) {
    if (state.selectedPlaylist == null) return;
    final updatedList = List<PlaylistTrackItem>.from(
      state.selectedPlaylist!.tracks,
    );
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);
    final newPlaylist = Playlist(
      id: state.selectedPlaylist!.id,
      title: state.selectedPlaylist!.title,
      isPublic: state.selectedPlaylist!.isPublic,
      tracks: updatedList,
      shareCount: state.selectedPlaylist!.shareCount,
    );
    state = state.copyWith(selectedPlaylist: newPlaylist);
  }

  void removeTrack(PlaylistTrackItem item) {
    if (state.selectedPlaylist == null) return;
    final newPlaylistTracks = List<PlaylistTrackItem>.from(
      state.selectedPlaylist!.tracks,
    )..remove(item);
    final newSelectedTracks = Set<PlaylistTrackItem>.from(state.selectedTracks)
      ..remove(item);
    final newPlaylist = Playlist(
      id: state.selectedPlaylist!.id,
      title: state.selectedPlaylist!.title,
      isPublic: state.selectedPlaylist!.isPublic,
      tracks: newPlaylistTracks,
      shareCount: state.selectedPlaylist!.shareCount,
    );
    state = state.copyWith(
      selectedPlaylist: newPlaylist,
      selectedTracks: newSelectedTracks,
    );
  }
}

final playlistViewModelProvider =
    StateNotifierProvider<PlaylistViewModel, PlaylistState>(
      (ref) => PlaylistViewModel(),
    );

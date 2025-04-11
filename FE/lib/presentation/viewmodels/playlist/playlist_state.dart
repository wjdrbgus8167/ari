// lib/presentation/viewmodels/playlist/playlist_state.dart
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/domain/entities/playlist_trackitem.dart';

class PlaylistState {
  final Playlist? selectedPlaylist;
  final List<Playlist> playlists;
  final Set<PlaylistTrackItem> selectedTracks;
  final List<PlaylistTrackItem>? filteredTracks;

  PlaylistState({
    this.selectedPlaylist,
    this.playlists = const [],
    required this.selectedTracks,
    this.filteredTracks,
  });

  bool get selectionMode => selectedTracks.isNotEmpty;

  PlaylistState copyWith({
    Playlist? selectedPlaylist,
    List<Playlist>? playlists,
    Set<PlaylistTrackItem>? selectedTracks,
    List<PlaylistTrackItem>? filteredTracks,
  }) {
    return PlaylistState(
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
      playlists: playlists ?? this.playlists,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
    );
  }
}

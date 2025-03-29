import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/playlist_trackitem.dart';

class PlaylistState {
  final Playlist? selectedPlaylist;
  final Set<PlaylistTrackItem> selectedTracks;
  final String searchQuery;
  final List<PlaylistTrackItem> filteredTracks;

  PlaylistState({
    this.selectedPlaylist,
    required this.selectedTracks,
    this.searchQuery = '',
    this.filteredTracks = const [],
  });

  PlaylistState copyWith({
    Playlist? selectedPlaylist,
    Set<PlaylistTrackItem>? selectedTracks,
    String? searchQuery,
    List<PlaylistTrackItem>? filteredTracks,
  }) {
    return PlaylistState(
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredTracks: filteredTracks ?? this.filteredTracks,
    );
  }
}

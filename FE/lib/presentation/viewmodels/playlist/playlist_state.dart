import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/playlist_trackitem.dart';

class PlaylistState {
  final Playlist? selectedPlaylist;
  final Set<PlaylistTrackItem> selectedTracks;
  final String searchQuery;

  PlaylistState({
    this.selectedPlaylist,
    required this.selectedTracks,
    this.searchQuery = '',
  });

  PlaylistState copyWith({
    Playlist? selectedPlaylist,
    Set<PlaylistTrackItem>? selectedTracks,
    String? searchQuery,
  }) {
    return PlaylistState(
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

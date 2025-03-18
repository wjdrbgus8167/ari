import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/album_filter.dart';
import '../../../dummy_data/mock_data.dart';
import '../../../data/models/album.dart';
import '../../../core/utils/genre_utils.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel()
    : super(
        HomeState(
          selectedGenreLatest: Genre.all,
          selectedGenrePopular: Genre.all,
          latestAlbums: MockData.getLatestAlbums(),
          popularAlbums: MockData.getPopularAlbums(),
          popularPlaylists: MockData.getPopularPlaylists(),
          hot50Titles: MockData.getHot50Titles(),
        ),
      );

  void updateGenreLatest(String genreName) {
    final genre = getGenreFromDisplayName(genreName);
    state = state.copyWith(
      selectedGenreLatest: genre,
      filteredLatestAlbums: filterAlbumsByGenre(state.latestAlbums, genre),
    );
  }

  void updateGenrePopular(String genreName) {
    final genre = getGenreFromDisplayName(genreName);
    state = state.copyWith(
      selectedGenrePopular: genre,
      filteredPopularAlbums: filterAlbumsByGenre(state.popularAlbums, genre),
    );
  }
}

/// ✅ **HomeState 클래스 (ViewModel의 상태)**
class HomeState {
  final Genre selectedGenreLatest;
  final Genre selectedGenrePopular;
  final List<Album> latestAlbums;
  final List<Album> popularAlbums;
  final List<Album> filteredLatestAlbums;
  final List<Album> filteredPopularAlbums;
  final List<Playlist> popularPlaylists;
  final List<Track> hot50Titles;

  HomeState({
    required this.selectedGenreLatest,
    required this.selectedGenrePopular,
    required this.latestAlbums,
    required this.popularAlbums,
    List<Album>? filteredLatestAlbums,
    List<Album>? filteredPopularAlbums,
    required this.popularPlaylists,
    required this.hot50Titles,
  }) : filteredLatestAlbums = filteredLatestAlbums ?? latestAlbums,
       filteredPopularAlbums = filteredPopularAlbums ?? popularAlbums;

  HomeState copyWith({
    Genre? selectedGenreLatest,
    Genre? selectedGenrePopular,
    List<Album>? filteredLatestAlbums,
    List<Album>? filteredPopularAlbums,
  }) {
    return HomeState(
      selectedGenreLatest: selectedGenreLatest ?? this.selectedGenreLatest,
      selectedGenrePopular: selectedGenrePopular ?? this.selectedGenrePopular,
      latestAlbums: latestAlbums,
      popularAlbums: popularAlbums,
      filteredLatestAlbums: filteredLatestAlbums ?? this.filteredLatestAlbums,
      filteredPopularAlbums:
          filteredPopularAlbums ?? this.filteredPopularAlbums,
      popularPlaylists: popularPlaylists,
      hot50Titles: hot50Titles,
    );
  }
}

import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/domain/entities/album.dart'; // 도메인 엔티티 Album 사용
import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/track.dart';
import 'package:ari/core/utils/album_filter.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';
import 'package:ari/domain/repositories/album_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    List<Album>? latestAlbums,
    List<Album>? popularAlbums,
    List<Album>? filteredLatestAlbums,
    List<Album>? filteredPopularAlbums,
    List<Playlist>? popularPlaylists,
    List<Track>? hot50Titles,
  }) {
    return HomeState(
      selectedGenreLatest: selectedGenreLatest ?? this.selectedGenreLatest,
      selectedGenrePopular: selectedGenrePopular ?? this.selectedGenrePopular,
      latestAlbums: latestAlbums ?? this.latestAlbums,
      popularAlbums: popularAlbums ?? this.popularAlbums,
      filteredLatestAlbums: filteredLatestAlbums ?? this.filteredLatestAlbums,
      filteredPopularAlbums:
          filteredPopularAlbums ?? this.filteredPopularAlbums,
      popularPlaylists: popularPlaylists ?? this.popularPlaylists,
      hot50Titles: hot50Titles ?? this.hot50Titles,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final GetChartsUseCase getChartsUseCase;
  final AlbumRepository albumRepository; // 최신/인기 앨범 데이터 위해 추가
  final IPlaylistRemoteDataSource playlistRemoteDataSource;

  HomeViewModel({
    required this.getChartsUseCase,
    required this.playlistRemoteDataSource,
    required this.albumRepository,
  }) : super(
         HomeState(
           selectedGenreLatest: Genre.all,
           selectedGenrePopular: Genre.all,
           popularPlaylists: [],
           hot50Titles: [],
           latestAlbums: [],
           popularAlbums: [],
         ),
       ) {
    loadHot50Titles();
    loadPopularPlaylists();
    loadLatestAlbums();
    loadPopularAlbums();
  }

  Future<void> loadHot50Titles() async {
    try {
      print('[DEBUG] loadHot50Titles: API 호출 전');
      final chartItems = await getChartsUseCase.execute();
      print('[DEBUG] loadHot50Titles: API 응답 받은 chartItems: $chartItems');

      final List<Track> convertedTracks =
          chartItems.map((chart) {
            return Track(
              id: chart.trackId,
              trackTitle: chart.trackTitle,
              artist: chart.artist,
              composer: '',
              lyricist: '',
              albumId: chart.albumId,
              trackFileUrl: chart.trackFileUrl,
              lyrics: '',
              trackLikeCount: 0,
              coverUrl: chart.coverImageUrl,
            );
          }).toList();
      print('[DEBUG] loadHot50Titles: 변환된 Track 리스트: $convertedTracks');

      state = state.copyWith(hot50Titles: convertedTracks);
      print('[DEBUG] loadHot50Titles: 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] loadHot50Titles: 차트 데이터 로드 실패: $e');
    }
  }

  Future<void> loadPopularPlaylists() async {
    try {
      print('[DEBUG] loadPopularPlaylists: API 호출 전');
      final popular = await playlistRemoteDataSource.fetchPopularPlaylists();
      print('[DEBUG] loadPopularPlaylists: API 응답 받은 인기 플레이리스트: $popular');

      state = state.copyWith(popularPlaylists: popular);
      print('[DEBUG] loadPopularPlaylists: 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] loadPopularPlaylists: 인기 플레이리스트 로드 실패: $e');
    }
  }

  Future<void> loadLatestAlbums() async {
    try {
      final result = await albumRepository.fetchLatestAlbums();
      result.fold((failure) => print("최신 앨범 로드 실패: ${failure.message}"), (
        albums,
      ) {
        state = state.copyWith(
          latestAlbums: albums,
          filteredLatestAlbums: albums,
        );
      });
    } catch (e) {
      print("최신 앨범 로드 중 예외 발생: $e");
    }
  }

  Future<void> loadPopularAlbums() async {
    try {
      final result = await albumRepository.fetchPopularAlbums();
      result.fold((failure) => print("인기 앨범 로드 실패: ${failure.message}"), (
        albums,
      ) {
        state = state.copyWith(
          popularAlbums: albums,
          filteredPopularAlbums: albums,
        );
      });
    } catch (e) {
      print("인기 앨범 로드 중 예외 발생: $e");
    }
  }

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

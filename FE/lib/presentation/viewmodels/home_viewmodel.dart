import 'package:ari/data/datasources/playlist/playlist_remote_datasource.dart';
import 'package:ari/data/models/playlist.dart' as data;
import 'package:ari/data/mappers/playlist_trackitem_mapper.dart';

import 'package:ari/core/utils/album_filter.dart';
import 'package:ari/core/utils/genre_utils.dart';

import 'package:ari/domain/entities/album.dart';
import 'package:ari/domain/entities/playlist.dart' as domain;
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/domain/repositories/album/album_detail_repository.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final Genre selectedGenreLatest;
  final Genre selectedGenrePopular;
  final List<Album> latestAlbums;
  final List<Album> popularAlbums;
  final List<Album> filteredLatestAlbums;
  final List<Album> filteredPopularAlbums;
  final List<domain.Playlist> popularPlaylists;
  final List<domain.Track> hot50Titles;

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
    List<domain.Playlist>? popularPlaylists,
    List<domain.Track>? hot50Titles,
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
  final AlbumRepository albumRepository;
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

  /// ✅ 차트 데이터 로딩
  Future<void> loadHot50Titles() async {
    try {
      final chartItems = await getChartsUseCase.execute();
      final List<domain.Track> convertedTracks =
          chartItems.map((chart) {
            return domain.Track(
              trackId: chart.trackId,
              artistId: 0,
              trackTitle: chart.trackTitle,
              artistName: chart.artist,
              composer: [],
              lyricist: [],
              albumId: chart.albumId,
              albumTitle: '',
              genreName: '',
              trackNumber: 0,
              commentCount: 0,
              comments: [],
              createdAt: '',
              trackFileUrl: chart.trackFileUrl,
              lyric: '',
              trackLikeCount: 0,
              coverUrl: chart.coverImageUrl,
            );
          }).toList();

      state = state.copyWith(hot50Titles: convertedTracks);
    } catch (e) {
      print('loadHot50Titles error: $e');
    }
  }

  /// ✅ 인기 플레이리스트 로딩 (데이터 모델 → 도메인 모델 변환)
  Future<void> loadPopularPlaylists() async {
    try {
      final popular = await playlistRemoteDataSource.fetchPopularPlaylists();
      final domainPlaylists = popular.map(_mapDataPlaylistToDomain).toList();
      state = state.copyWith(popularPlaylists: domainPlaylists);
    } catch (e) {
      print('loadPopularPlaylists error: $e');
    }
  }

  /// 데이터 모델 Playlist → 도메인 엔티티 Playlist 변환
  domain.Playlist _mapDataPlaylistToDomain(data.Playlist playlist) {
    return domain.Playlist(
      id: playlist.id,
      title: playlist.title,
      coverImageUrl: playlist.coverImageUrl,
      isPublic: playlist.isPublic,
      trackCount: playlist.trackCount,
      shareCount: playlist.shareCount,
      tracks: playlist.tracks.map(toEntityTrack).toList(),
    );
  }

  /// ✅ 최신 앨범 로딩
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
      print("최신 앨범 로드 예외: $e");
    }
  }

  /// ✅ 인기 앨범 로딩
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
      print("인기 앨범 로드 예외: $e");
    }
  }

  /// ✅ 최신앨범 장르 필터링
  void updateGenreLatest(String genreName) {
    final genre = getGenreFromDisplayName(genreName);
    state = state.copyWith(
      selectedGenreLatest: genre,
      filteredLatestAlbums: filterAlbumsByGenre(state.latestAlbums, genre),
    );
  }

  /// ✅ 인기앨범 장르 필터링
  void updateGenrePopular(String genreName) {
    final genre = getGenreFromDisplayName(genreName);
    state = state.copyWith(
      selectedGenrePopular: genre,
      filteredPopularAlbums: filterAlbumsByGenre(state.popularAlbums, genre),
    );
  }
}

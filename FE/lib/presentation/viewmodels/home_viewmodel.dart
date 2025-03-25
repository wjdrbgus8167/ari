import 'package:ari/data/models/playlist.dart';
import 'package:ari/data/models/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/utils/album_filter.dart';
import 'package:ari/dummy_data/mock_data.dart';
import 'package:ari/data/models/album.dart';
import 'package:ari/core/utils/genre_utils.dart';
import 'package:ari/domain/usecases/get_charts_usecase.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  final GetChartsUseCase getChartsUseCase;

  HomeViewModel({required this.getChartsUseCase})
    : super(
        HomeState(
          selectedGenreLatest: Genre.all,
          selectedGenrePopular: Genre.all,
          latestAlbums: MockData.getLatestAlbums(),
          popularAlbums: MockData.getPopularAlbums(),
          popularPlaylists: MockData.getPopularPlaylists(),
          hot50Titles: [],
        ),
      ) {
    // 생성자에서 차트 데이터를 비동기로 로드
    loadHot50Titles();
  }

  Future<void> loadHot50Titles() async {
    try {
      print('[DEBUG] loadHot50Titles: API 호출 전');
      // GetChartsUseCase로부터 차트 데이터를 ChartItem 리스트로 받아옴.
      final chartItems = await getChartsUseCase.execute();
      print('[DEBUG] loadHot50Titles: API 응답 받은 chartItems: $chartItems');

      // ChartItem 리스트를 Track 리스트로 변환함.
      final List<Track> convertedTracks =
          chartItems.map((chart) {
            return Track(
              id: chart.trackId, // ChartItem의 trackId를 Track의 id로 사용
              trackTitle: chart.trackTitle,
              artist: chart.artist,
              composer: '', // 필요한 경우 적절한 값으로 대체
              lyricist: '', // 필요한 경우 적절한 값으로 대체
              albumId: '', // 필요한 경우 적절한 값으로 대체
              trackFileUrl: '', // 필요한 경우 적절한 값으로 대체
              lyrics: '', // 필요한 경우 적절한 값으로 대체
              trackLikeCount: 0, // 기본값 설정
              coverUrl: chart.coverImageUrl, // ChartItem의 coverImageUrl 사용
            );
          }).toList();
      print('[DEBUG] loadHot50Titles: 변환된 Track 리스트: $convertedTracks');

      // 상태 업데이트
      state = state.copyWith(hot50Titles: convertedTracks);
      print('[DEBUG] loadHot50Titles: 상태 업데이트 완료');
    } catch (e) {
      print('[ERROR] loadHot50Titles: 차트 데이터 로드 실패: $e');
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
    List<Track>? hot50Titles,
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
      hot50Titles: hot50Titles ?? this.hot50Titles,
    );
  }
}

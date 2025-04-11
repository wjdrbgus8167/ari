import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'playlist_state.dart';
import 'package:ari/domain/repositories/playlist_repository.dart';

class PlaylistViewModel extends StateNotifier<PlaylistState> {
  final IPlaylistRepository playlistRepository;

  PlaylistViewModel({required this.playlistRepository})
    : super(PlaylistState(selectedTracks: {}));

  /// 원격 API로부터 플레이리스트 목록을 가져와 상태를 업데이트합니다.
  Future<void> fetchPlaylists() async {
    try {
      final playlists = await playlistRepository.fetchPlaylists();
      print('[DEBUG] fetchPlaylists: playlists.length = ${playlists.length}');

      if (playlists.isNotEmpty) {
        state = state.copyWith(playlists: playlists);

        setPlaylist(playlists.first);
      }
    } catch (e) {
      // 오류 처리 (예: 로그 출력, 에러 상태 업데이트 등)
      print('플레이리스트 조회 오류: $e');
    }
  }

  Future<void> createPlaylistAndAddTracks(
    String title,
    bool publicYn,
    List<PlaylistTrackItem> selectedItems,
  ) async {
    final request = PlaylistCreateRequest(title: title, publicYn: publicYn);
    final newPlaylist = await playlistRepository.createPlaylist(request);

    for (var item in selectedItems) {
      await playlistRepository.addTrack(newPlaylist.id, item.trackId);
    }

    print('[DEBUG] 새 플레이리스트 생성 및 트랙 추가 완료');
  }

  Future<void> setPlaylist(Playlist basePlaylist) async {
    // 1. 목록 조회 API로 받아온 기본 정보를 상태에 설정합니다.
    state = state.copyWith(selectedPlaylist: basePlaylist, selectedTracks: {});
    print(
      'setPlaylist - 기본 플레이리스트: ${basePlaylist.title}, 트랙 수: ${basePlaylist.tracks.length}',
    );

    try {
      // 2. 상세조회 API 호출하여 트랙 목록만 가져옵니다.
      final detailedPlaylist = await playlistRepository.getPlaylistDetail(
        basePlaylist.id,
      );
      print(
        'setPlaylist - 상세조회 API 반환 트랙 수: ${detailedPlaylist.tracks.length}',
      );

      // 3. 목록 조회 API의 기본 정보와 상세조회 API의 트랙 목록을 병합합니다.
      final mergedPlaylist = Playlist(
        id: basePlaylist.id,
        title: basePlaylist.title,
        coverImageUrl: basePlaylist.coverImageUrl,
        isPublic: basePlaylist.isPublic,
        trackCount: detailedPlaylist.tracks.length,
        shareCount: basePlaylist.shareCount,
        tracks: detailedPlaylist.tracks,
      );
      print('setPlaylist - 병합된 플레이리스트 트랙 수: ${mergedPlaylist.tracks.length}');

      // 4. 최종 병합된 플레이리스트를 상태에 업데이트합니다.
      state = state.copyWith(selectedPlaylist: mergedPlaylist);
    } catch (e) {
      print('플레이리스트 상세조회 오류: $e');
    }
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
          final title = item.trackTitle.toLowerCase();
          final artist = item.artist.toLowerCase();
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
      coverImageUrl: state.selectedPlaylist!.coverImageUrl,
      isPublic: state.selectedPlaylist!.isPublic,
      trackCount: updatedList.length,
      shareCount: state.selectedPlaylist!.shareCount,
      tracks: updatedList,
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
      coverImageUrl: state.selectedPlaylist!.coverImageUrl,
      isPublic: state.selectedPlaylist!.isPublic,
      trackCount: newPlaylistTracks.length,
      shareCount: state.selectedPlaylist!.shareCount,
      tracks: newPlaylistTracks,
    );
    state = state.copyWith(
      selectedPlaylist: newPlaylist,
      selectedTracks: newSelectedTracks,
    );
  }

  void deleteTrack(PlaylistTrackItem item) {
    removeTrack(item);
  }
}

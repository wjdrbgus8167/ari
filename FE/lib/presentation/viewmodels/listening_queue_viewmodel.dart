import 'package:ari/data/models/track.dart' as data;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/data/datasources/local/local_listening_queue_datasource.dart';
import 'package:ari/data/models/listening_queue_item.dart';
import 'package:ari/data/dto/playlist_create_request.dart';
import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/domain/entities/playlist.dart';
import 'package:ari/domain/repositories/playlist_repository.dart';

/// 데이터 모델인 data.Track을 도메인 엔티티 domain.Track으로 변환하는 매핑 함수
domain.Track mapDataTrackToDomain(data.Track dataTrack) {
  return domain.Track(
    trackId: dataTrack.id ?? 0,
    trackTitle: dataTrack.trackTitle,
    artistName: dataTrack.artist,
    albumTitle: '',
    genreName: '',
    // 단일 문자열을 리스트로 감싸서 전달 (필요시 로직 변경)
    composer: [dataTrack.composer],
    lyricist: [dataTrack.lyricist],
    albumId: dataTrack.albumId ?? 0,
    trackFileUrl: dataTrack.trackFileUrl,
    lyric: dataTrack.lyrics,
    coverUrl: dataTrack.coverUrl,
    trackLikeCount: dataTrack.trackLikeCount ?? 0,
    commentCount: 0, // 기본값 (필요에 따라 수정)
    comments: [], // 기본값 (필요에 따라 수정)
    trackNumber: 0, // 기본값 (필요에 따라 수정)
    createdAt: DateTime.now().toString(), // 생성 시각 (필요시 변경)
  );
}

/// 재생목록 상태 클래스
class ListeningQueueState {
  final List<ListeningQueueItem> playlist;
  final List<ListeningQueueItem> filteredPlaylist;
  final Set<ListeningQueueItem> selectedTracks;
  final List<Playlist> playlists;
  final bool isLoading;

  ListeningQueueState({
    required this.playlist,
    required this.filteredPlaylist,
    required this.selectedTracks,
    this.playlists = const [],
    this.isLoading = true,
  });

  ListeningQueueState copyWith({
    List<ListeningQueueItem>? playlist,
    List<ListeningQueueItem>? filteredPlaylist,
    Set<ListeningQueueItem>? selectedTracks,
    List<Playlist>? playlists,
    bool? isLoading,
  }) {
    return ListeningQueueState(
      playlist: playlist ?? this.playlist,
      filteredPlaylist: filteredPlaylist ?? this.filteredPlaylist,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// ViewModel: 로컬 저장소(Hive)에 저장된 사용자별 재생목록을 관리하며,
/// PlaylistRepository를 통해 플레이리스트 관련 작업을 수행합니다.
class ListeningQueueViewModel extends StateNotifier<ListeningQueueState> {
  final String userId;
  final IPlaylistRepository playlistRepository;

  ListeningQueueViewModel({
    required this.userId,
    required this.playlistRepository,
  }) : super(
         ListeningQueueState(
           playlist: [],
           filteredPlaylist: [],
           selectedTracks: {},
           playlists: [],
         ),
       ) {
    loadQueue();
    _loadPlaylists();
  }

  // 재생목록을 로드합니다.
  Future<void> loadQueue() async {
    final dataTracks = await loadListeningQueue(userId); // List<data.Track>
    final domainTracks =
        dataTracks.map((dataTrack) => mapDataTrackToDomain(dataTrack)).toList();
    final items =
        domainTracks.map((track) => ListeningQueueItem(track: track)).toList();

    if (!mounted) return;

    state = state.copyWith(
      playlist: items,
      filteredPlaylist: List.from(items),
      isLoading: false,
    );
  }

  // 플레이리스트 목록을 불러옵니다.
  Future<void> _loadPlaylists() async {
    try {
      final playlists = await playlistRepository.fetchPlaylists();
      // if (!mounted) return;
      state = state.copyWith(playlists: playlists);
    } catch (e) {
      print('[ERROR] 플레이리스트 조회 중 에러 발생: $e');
    }
  }

  // 트랙이 재생될 때 자동으로 재생목록에 추가합니다.
  Future<void> trackPlayed(data.Track track) async {
    await addTrackToListeningQueue(userId, track);
    await loadQueue();
  }

  // 트랙을 검색해서 재생목록을 필터링합니다.
  void filterTracks(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredPlaylist: List.from(state.playlist));
    } else {
      final filtered =
          state.playlist.where((item) {
            return item.track.trackTitle.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                item.track.artistName.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
      state = state.copyWith(filteredPlaylist: filtered);
    }
  }

  // 트랙 선택 여부를 토글합니다.
  void toggleTrackSelection(ListeningQueueItem item) {
    final newSelected = Set<ListeningQueueItem>.from(state.selectedTracks);
    if (newSelected.contains(item)) {
      newSelected.remove(item);
    } else {
      newSelected.add(item);
    }
    state = state.copyWith(selectedTracks: newSelected);
  }

  // 모든 트랙 선택 또는 해제합니다.
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

  // 재생목록 순서를 변경합니다.
  Future<void> reorderTracks(int oldIndex, int newIndex) async {
    final updatedList = List<ListeningQueueItem>.from(state.filteredPlaylist);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);
    final tracksOrder = updatedList.map((i) => i.track.toDataModel()).toList();
    await updateListeningQueueOrder(userId, tracksOrder);
    state = state.copyWith(filteredPlaylist: updatedList);
    await loadQueue();
  }

  // 트랙을 삭제합니다.
  Future<void> removeTrack(ListeningQueueItem item) async {
    await removeTrackFromListeningQueue(userId, item.track.trackId);
    await loadQueue();
    final newSelected = Set<ListeningQueueItem>.from(state.selectedTracks)
      ..remove(item);
    state = state.copyWith(selectedTracks: newSelected);
  }

  // 선택된 트랙들을 플레이리스트에 추가합니다.
  Future<void> addSelectedTracksToPlaylist(
    Playlist selectedPlaylist,
    List<ListeningQueueItem> selectedItems,
  ) async {
    for (var item in selectedItems) {
      await playlistRepository.addTrack(
        selectedPlaylist.id,
        item.track.trackId,
      );
    }
    state = state.copyWith(selectedTracks: {});
  }

  // 새 플레이리스트를 만들고 트랙들을 추가합니다.
  Future<void> createPlaylistAndAddTracks(
    String title,
    bool publicYn,
    List<ListeningQueueItem> selectedItems,
  ) async {
    final request = PlaylistCreateRequest(title: title, publicYn: publicYn);
    final newPlaylist = await playlistRepository.createPlaylist(request);
    for (var item in selectedItems) {
      await playlistRepository.addTrack(newPlaylist.id, item.track.trackId);
    }
    await _loadPlaylists();
    state = state.copyWith(selectedTracks: {});
  }
}

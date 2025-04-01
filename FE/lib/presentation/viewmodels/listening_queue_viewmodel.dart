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
    trackId: dataTrack.id,
    trackTitle: dataTrack.trackTitle,
    artistName: dataTrack.artist,
    // 단일 문자열을 리스트로 감싸서 전달 (필요시 로직 변경)
    composer: [dataTrack.composer],
    lyricist: [dataTrack.lyricist],
    albumId: int.parse(dataTrack.albumId),
    trackFileUrl: dataTrack.trackFileUrl,
    lyric: dataTrack.lyrics,
    coverUrl: dataTrack.coverUrl,
    trackLikeCount: dataTrack.trackLikeCount,
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

  ListeningQueueState({
    required this.playlist,
    required this.filteredPlaylist,
    required this.selectedTracks,
    this.playlists = const [],
  });

  ListeningQueueState copyWith({
    List<ListeningQueueItem>? playlist,
    List<ListeningQueueItem>? filteredPlaylist,
    Set<ListeningQueueItem>? selectedTracks,
    List<Playlist>? playlists,
  }) {
    return ListeningQueueState(
      playlist: playlist ?? this.playlist,
      filteredPlaylist: filteredPlaylist ?? this.filteredPlaylist,
      selectedTracks: selectedTracks ?? this.selectedTracks,
      playlists: playlists ?? this.playlists,
    );
  }
}

/// ViewModel: 로컬 저장소(Hive)에 저장된 사용자별 재생목록을 관리하며,
/// PlaylistRepository를 통해 플레이리스트 관련 작업을 수행합니다.
class ListeningQueueViewModel extends StateNotifier<ListeningQueueState> {
  final String userId;
  final IPlaylistRepository playlistRepository; // repository 주입

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
    _loadQueue();
    _loadPlaylists();
  }

  /// 로컬 저장소에서 재생목록을 불러옵니다.
  Future<void> _loadQueue() async {
    // data 모델 타입의 트랙을 불러옴
    final dataTracks = await loadListeningQueue(userId); // List<data.Track>
    // data 모델을 도메인 엔티티로 변환
    final domainTracks =
        dataTracks.map((dataTrack) => mapDataTrackToDomain(dataTrack)).toList();
    final items =
        domainTracks.map((track) => ListeningQueueItem(track: track)).toList();
    state = state.copyWith(playlist: items, filteredPlaylist: List.from(items));
  }

  /// PlaylistRepository를 통해 플레이리스트 목록을 불러옵니다.
  Future<void> _loadPlaylists() async {
    try {
      print('[DEBUG] 플레이리스트 조회 시작');
      final playlists = await playlistRepository.fetchPlaylists();
      print('[DEBUG] 조회된 플레이리스트: $playlists');
      state = state.copyWith(playlists: playlists);
    } catch (e) {
      print('[ERROR] 플레이리스트 조회 중 에러 발생: $e');
    }
  }

  /// 특정 트랙이 재생될 때 자동으로 재생목록에 추가합니다.
  Future<void> trackPlayed(data.Track track) async {
    await addTrackToListeningQueue(userId, track);
    await _loadQueue();
  }

  /// 검색어에 따라 재생목록을 필터링합니다.
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

  /// 특정 항목의 선택 여부를 토글합니다.
  void toggleTrackSelection(ListeningQueueItem item) {
    final newSelected = Set<ListeningQueueItem>.from(state.selectedTracks);
    if (newSelected.contains(item)) {
      newSelected.remove(item);
    } else {
      newSelected.add(item);
    }
    state = state.copyWith(selectedTracks: newSelected);
  }

  /// 전체 선택 또는 해제 기능.
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

  /// 재생목록의 순서를 변경하고, 로컬 저장소에 업데이트합니다.
  Future<void> reorderTracks(int oldIndex, int newIndex) async {
    final updatedList = List<ListeningQueueItem>.from(state.filteredPlaylist);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);
    // domain.Track 리스트를 data.Track 리스트로 변환
    final tracksOrder = updatedList.map((i) => i.track.toDataModel()).toList();
    await updateListeningQueueOrder(userId, tracksOrder);
    state = state.copyWith(filteredPlaylist: updatedList);
    await _loadQueue();
  }

  /// 재생목록에서 특정 항목을 삭제하고, 상태를 업데이트합니다.
  Future<void> removeTrack(ListeningQueueItem item) async {
    await removeTrackFromListeningQueue(userId, item.track.trackId);
    await _loadQueue();
    final newSelected = Set<ListeningQueueItem>.from(state.selectedTracks)
      ..remove(item);
    state = state.copyWith(selectedTracks: newSelected);
  }

  /// 선택된 트랙들을 기존 플레이리스트에 추가합니다.
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
    // 추가 후 선택 상태 초기화
    state = state.copyWith(selectedTracks: {});
  }

  /// 새 플레이리스트를 생성한 후 선택된 트랙들을 추가합니다.
  Future<void> createPlaylistAndAddTracks(
    String title,
    bool publicYn,
    List<ListeningQueueItem> selectedItems,
  ) async {
    final request = PlaylistCreateRequest(title: title, isPublic: publicYn);
    final newPlaylist = await playlistRepository.createPlaylist(request);
    for (var item in selectedItems) {
      await playlistRepository.addTrack(newPlaylist.id, item.track.trackId);
    }
    // 새 플레이리스트 생성 후 플레이리스트 목록 업데이트
    await _loadPlaylists();
    state = state.copyWith(selectedTracks: {});
  }
}

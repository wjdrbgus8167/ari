import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/common/track_count_bar.dart';
import 'package:ari/presentation/widgets/listening_queue/track_list_tile.dart';
import 'package:ari/presentation/widgets/listening_queue/bottom_sheet_options.dart';
import 'package:ari/presentation/widgets/common/global_bottom_widget.dart';
import 'package:ari/presentation/widgets/common/search_bar.dart';
import 'package:ari/presentation/widgets/listening_queue/playlist_selection_bottom_sheet.dart';
import 'package:ari/presentation/widgets/listening_queue/create_playlist_modal.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeningQueueScreen extends ConsumerStatefulWidget {
  const ListeningQueueScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ListeningQueueScreen> createState() =>
      _ListeningQueueScreenState();
}

class _ListeningQueueScreenState extends ConsumerState<ListeningQueueScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    // listeningQueueProvider의 상태
    final state = ref.watch(listeningQueueProvider);
    final viewModel = ref.read(listeningQueueProvider.notifier);
    // playbackProvider의 상태를 받아 현재 재생 중인 트랙 정보 확인
    final playbackState = ref.watch(playbackProvider);

    return GlobalBottomWidget(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            ListeningQueueAppBar(
              onBack: () => Navigator.pop(context),
              onSearch: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;
                });
              },
              selectedTab: ListeningTab.listeningQueue,
              onTabChanged: (tab) {
                if (tab != ListeningTab.listeningQueue) {
                  Navigator.pushReplacementNamed(context, '/playlist');
                }
              },
            ),
            if (isSearchVisible)
              SearchBarWidget(
                controller: searchController,
                hintText: "곡 제목 또는 아티스트 검색",
                onChanged: viewModel.filterTracks,
                onSubmitted: viewModel.filterTracks,
              ),
            const SizedBox(height: 10),
            TrackCountBar(
              trackCount: state.filteredPlaylist.length,
              selectedTracks:
                  state.selectedTracks.map((item) => item.track).toSet(),
              onToggleSelectAll: viewModel.toggleSelectAll,
              onAddToPlaylist: () {
                // "플레이리스트에 추가" 버튼 클릭 시 PlaylistSelectionBottomSheet 표시
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => PlaylistSelectionBottomSheet(
                        playlists: state.playlists,
                        onPlaylistSelected: (selectedPlaylist) {
                          // 선택한 플레이리스트에 선택된 트랙들을 추가하는 로직 실행
                          viewModel.addSelectedTracksToPlaylist(
                            selectedPlaylist,
                            state.selectedTracks.toList(),
                          );
                        },
                        onCreatePlaylist: () {
                          Navigator.pop(context); // 기존 BottomSheet 닫기
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return CreatePlaylistModal(
                                onCreate: (title, publicYn) {
                                  debugPrint(
                                    "플레이리스트 생성: $title / 공개여부: $publicYn",
                                  );
                                  viewModel.createPlaylistAndAddTracks(
                                    title,
                                    publicYn,
                                    state.selectedTracks.toList(),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                );
              },
            ),
            Expanded(
              child:
                  state.filteredPlaylist.isEmpty
                      ? const Center(
                        child: Text(
                          "재생 목록이 없습니다.",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                      : ReorderableListView.builder(
                        onReorder: viewModel.reorderTracks,
                        itemCount: state.filteredPlaylist.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredPlaylist[index];
                          // 현재 재생 상태와 비교하여, 같은 트랙 id가 여러 개 있더라도 첫 번째 인스턴스에만 표시
                          final playbackState = ref.watch(playbackProvider);
                          final firstOccurrenceIndex = state.filteredPlaylist
                              .indexWhere(
                                (element) =>
                                    element.track.trackId ==
                                    playbackState.currentTrackId,
                              );
                          final isPlayingIndicator =
                              playbackState.isPlaying &&
                              playbackState.currentTrackId ==
                                  item.track.trackId &&
                              index == firstOccurrenceIndex;

                          return Dismissible(
                            key: ValueKey(item.uniqueId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              viewModel.removeTrack(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${item.track.trackTitle} 삭제됨"),
                                ),
                              );
                            },
                            child: GestureDetector(
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder:
                                      (context) =>
                                          BottomSheetOptions(track: item.track),
                                );
                              },
                              child: TrackListTile(
                                key: ValueKey(item.uniqueId),
                                track: item.track,
                                isPlayingIndicator: isPlayingIndicator,
                                onTap: () {
                                  // 트랙 터치 시 AudioService를 통해 재생
                                  ref
                                      .read(audioServiceProvider)
                                      .play(
                                        ref,
                                        item.track.trackFileUrl ?? '',
                                        title: item.track.trackTitle,
                                        artist: item.track.artistName,
                                        coverImageUrl:
                                            item.track.coverUrl ?? '',
                                        lyrics: item.track.lyric,
                                        trackId: item.track.trackId,
                                        albumId: item.track.albumId,
                                        isLiked: false,
                                        currentQueueItemId: item.uniqueId,
                                      );
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

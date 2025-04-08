import 'package:ari/core/services/audio_service.dart';
import 'package:ari/presentation/widgets/common/bottom_nav.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/presentation/widgets/common/listeningqueue_container.dart';
import 'package:ari/presentation/widgets/common/playback_bar.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/common/track_count_bar.dart';
import 'package:ari/presentation/widgets/listening_queue/track_list_tile.dart';
import 'package:ari/presentation/widgets/listening_queue/bottom_sheet_options.dart';
import 'package:ari/presentation/widgets/common/search_bar.dart';
import 'package:ari/presentation/widgets/listening_queue/playlist_selection_bottom_sheet.dart';
import 'package:ari/presentation/widgets/listening_queue/create_playlist_modal.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeningQueueScreen extends ConsumerStatefulWidget {
  final ValueChanged<ListeningSubTab>? onTabChanged;

  const ListeningQueueScreen({super.key, this.onTabChanged});

  @override
  ConsumerState<ListeningQueueScreen> createState() =>
      _ListeningQueueScreenState();
}

class _ListeningQueueScreenState extends ConsumerState<ListeningQueueScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listeningQueueProvider);
    final viewModel = ref.read(listeningQueueProvider.notifier);
    final playbackState = ref.watch(playbackProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                if (tab == ListeningTab.playlist) {
                  widget.onTabChanged?.call(ListeningSubTab.playlist);
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
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => PlaylistSelectionBottomSheet(
                        playlists: state.playlists,
                        onPlaylistSelected: (selectedPlaylist) {
                          viewModel.addSelectedTracksToPlaylist(
                            selectedPlaylist,
                            state.selectedTracks.toList(),
                          );
                        },
                        onCreatePlaylist: () {
                          Navigator.pop(context);
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
                          final isPlayingIndicator =
                              playbackState.isPlaying &&
                              playbackState.currentQueueItemId == item.uniqueId;

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
                              context.showToast("${item.track.trackTitle} 삭제됨");
                            },
                            child: TrackListTile(
                              key: ValueKey(item.uniqueId),
                              track: item.track,
                              isSelected: state.selectedTracks.contains(item),
                              isPlayingIndicator: isPlayingIndicator,
                              onTap: () {
                                ref
                                    .read(audioServiceProvider)
                                    .playFromQueueSubset(
                                      context,
                                      ref,
                                      state.filteredPlaylist
                                          .map((e) => e.track)
                                          .toList(),
                                      item.track,
                                    );
                              },
                              onToggleSelection:
                                  () => viewModel.toggleTrackSelection(item),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlaybackBar(),
          CommonBottomNav(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/search');
              } else if (index == 2) {
                // 현재 탭
              } else if (index == 3) {
                Navigator.pushReplacementNamed(context, '/mychannel');
              }
            },
          ),
        ],
      ),
    );
  }
}

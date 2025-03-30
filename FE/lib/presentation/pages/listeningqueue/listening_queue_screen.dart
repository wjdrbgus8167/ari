import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/common/track_count_bar.dart';
import 'package:ari/presentation/widgets/listening_queue/track_list_tile.dart';
import 'package:ari/presentation/widgets/listening_queue/bottom_sheet_options.dart';
import 'package:ari/presentation/widgets/common/global_bottom_widget.dart';
import 'package:ari/presentation/widgets/common/search_bar.dart';

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
    final state = ref.watch(listeningQueueProvider);
    final viewModel = ref.read(listeningQueueProvider.notifier);

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

            //  검색창 표시
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
              selectedTracks: state.selectedTracks,
              onToggleSelectAll: viewModel.toggleSelectAll,
              onAddToPlaylist: () {
                for (var track in state.selectedTracks) {
                  print("추가할 트랙: ${track.trackTitle}");
                }
              },
            ),

            Expanded(
              child:
                  state.filteredPlaylist.isEmpty
                      ? const Center(
                        child: Text(
                          "재생목록이 없습니다.",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                      : ReorderableListView.builder(
                        onReorder: viewModel.reorderTracks,
                        itemCount: state.filteredPlaylist.length,
                        itemBuilder: (context, index) {
                          final track = state.filteredPlaylist[index];
                          final isSelected = state.selectedTracks.contains(
                            track,
                          );

                          return Dismissible(
                            key: ValueKey(track.id),
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
                              viewModel.removeTrack(track);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${track.trackTitle} 삭제됨"),
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
                                          BottomSheetOptions(track: track),
                                );
                              },
                              child: TrackListTile(
                                key: ValueKey(track.id),
                                track: track,
                                isSelected: isSelected,
                                onToggleSelection:
                                    () => viewModel.toggleTrackSelection(track),
                                onTap: () => print("${track.trackTitle} 선택됨!"),
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

import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/listening_queue_viewmodel.dart';
import '../../widgets/listening_queue/listening_queue_appbar.dart';
import '../../widgets/listening_queue/track_count_bar.dart';
import '../../widgets/listening_queue/track_list_tile.dart';
import '../../widgets/listening_queue/bottom_sheet_options.dart';

class ListeningQueueScreen extends ConsumerWidget {
  const ListeningQueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listeningQueueProvider);
    final viewModel = ref.read(listeningQueueProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ListeningQueueAppBar(
            onBack: () => Navigator.pop(context),
            onSearch: () => _showSearchDialog(context, viewModel),
          ),
          const SizedBox(height: 20),
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
                        final isSelected = state.selectedTracks.contains(track);
                        return Dismissible(
                          key: ValueKey(track.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  void _showSearchDialog(
    BuildContext context,
    ListeningQueueViewModel viewModel,
  ) {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text("곡 검색", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "곡 제목 또는 아티스트 입력",
              hintStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white70),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: viewModel.filterTracks,
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchController.clear();
                viewModel.filterTracks('');
                Navigator.pop(context);
              },
              child: const Text(
                "닫기",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/listening_queue_viewmodel.dart';
import '../../widgets/listening_queue/listening_queue_appbar.dart';
import '../../widgets/listening_queue/track_count_bar.dart';
import '../../widgets/listening_queue/track_list_tile.dart';
import '../../../data/models/track.dart';

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
                          key: ValueKey(track.id), // 고유한 키 사용
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
                                        _buildBottomSheet(context, track),
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

  Widget _buildBottomSheet(BuildContext context, Track track) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 트랙 정보 영역
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 커버 이미지
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: NetworkImage(
                        track.coverUrl ??
                            'assets/images/default_album_cover.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 트랙 제목과 아티스트
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.trackTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.artist,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 좋아요 버튼 (예시)
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // 좋아요 버튼 동작 추후에 구현
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text(
              '앨범으로 이동',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              // 앨범으로 이동하는 로직
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              '트랙 정보로 이동',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              // 트랙 정보로 이동하는 로직
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              '아티스트 채널로 이동',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              // 아티스트 채널로 이동하는 로직
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

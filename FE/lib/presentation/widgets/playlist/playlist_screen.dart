// lib/presentation/widgets/playlist/playlist_screen.dart
import 'package:ari/presentation/widgets/playlist/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/viewmodels/listening_queue_viewmodel.dart';
import 'package:ari/data/models/playlist.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/playlist/playlist_selectbar.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  // 현재 선택된 플레이리스트를 저장하는 상태
  Playlist? selectedPlaylist;

  void _updateSelectedPlaylist(Playlist newPlaylist) {
    setState(() {
      selectedPlaylist = newPlaylist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(listeningQueueProvider.notifier);
    // 전역 선택 상태: 선택된 트랙이 하나라도 있으면 선택 모드 활성화
    final selectedTracks = ref.watch(listeningQueueProvider).selectedTracks;
    final bool selectionMode = selectedTracks.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ListeningQueueAppBar(
            onBack: () => Navigator.pop(context),
            onSearch: () => _showSearchDialog(context, viewModel),
            selectedTab: ListeningTab.playlist,
            onTabChanged: (ListeningTab tab) {
              if (tab == ListeningTab.listeningQueue) {
                Navigator.pushReplacementNamed(context, '/listeningqueue');
              }
            },
          ),
          const SizedBox(height: 20),
          // PlaylistSelectbar와 삭제하기 버튼이 포함된 Row
          Row(
            children: [
              Expanded(
                child: PlaylistSelectbar(
                  onPlaylistSelected: _updateSelectedPlaylist,
                ),
              ),
              if (selectionMode)
                TextButton(
                  onPressed: () {
                    for (final track in selectedTracks) {
                      viewModel.removeTrack(track);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("선택된 트랙이 삭제되었습니다.")),
                    );
                  },
                  child: const Text(
                    "삭제하기",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                (selectedPlaylist == null || selectedPlaylist!.tracks.isEmpty)
                    ? const Center(
                      child: Text(
                        "플레이리스트가 없습니다.",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: selectedPlaylist!.tracks.length,
                      itemBuilder: (context, index) {
                        final playlistTrack = selectedPlaylist!.tracks[index];
                        final isSelected = selectedTracks.contains(
                          playlistTrack,
                        );
                        return PlaylistTrackListTile(
                          key: ValueKey(playlistTrack.track.trackTitle),
                          item: playlistTrack,
                          isSelected: isSelected,
                          selectionMode: selectionMode,
                          onToggleSelection:
                              () => viewModel.toggleTrackSelection(
                                playlistTrack.track,
                              ),
                          onTap:
                              () => print(
                                "${playlistTrack.track.trackTitle} 선택됨!",
                              ),
                          onDelete: () {}, // 삭제 아이콘은 제거되었으므로 빈 콜백
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

// lib/presentation/widgets/playlist/playlist_screen.dart
import 'package:ari/presentation/widgets/playlist/playlist_track_controls.dart';
import 'package:ari/presentation/widgets/playlist/playlist_track_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/common/listening_queue_appbar.dart';
import 'package:ari/presentation/widgets/playlist/playlist_selectbar.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistViewModelProvider);
    final playlistViewModel = ref.read(playlistViewModelProvider.notifier);

    // 전체 선택 여부: 만약 선택된 플레이리스트가 있다면 모든 트랙이 선택되었는지 확인
    bool allSelected = false;
    if (playlistState.selectedPlaylist != null &&
        playlistState.selectedPlaylist!.tracks.isNotEmpty) {
      allSelected = playlistState.selectedPlaylist!.tracks.every(
        (item) => playlistState.selectedTracks.contains(item),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ListeningQueueAppBar(
            onBack: () => Navigator.pop(context),
            onSearch: () {
              _showSearchDialog(context, playlistViewModel);
            },
            selectedTab: ListeningTab.playlist,
            onTabChanged: (ListeningTab tab) {
              if (tab == ListeningTab.listeningQueue) {
                Navigator.pushReplacementNamed(context, '/listeningqueue');
              }
            },
          ),
          const SizedBox(height: 20),
          // PlaylistSelectbar를 통해 플레이리스트 선택
          PlaylistSelectbar(
            onPlaylistSelected: (playlist) {
              playlistViewModel.setPlaylist(playlist);
            },
          ),
          const SizedBox(height: 10),
          // 전체 트랙 선택 바
          PlaylistTrackControls(),
          const SizedBox(height: 10),
          // 트랙 목록
          Expanded(
            child: PlaylistTrackList(), // ✅ 모듈화된 리스트 위젯 사용
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, PlaylistViewModel viewModel) {
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchController.clear();
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

import 'package:ari/presentation/widgets/playlist/playlist_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/viewmodels/playlist/playlist_viewmodel.dart';

class PlaylistTrackList extends ConsumerWidget {
  const PlaylistTrackList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistViewModelProvider);
    final viewModel = ref.read(playlistViewModelProvider.notifier);

    final playlist = state.selectedPlaylist;

    // ✅ 렌더링할 트랙 리스트를 filteredTracks 기준으로 결정
    final tracksToShow =
        state.filteredTracks.isNotEmpty
            ? state.filteredTracks
            : playlist?.tracks ?? [];

    if (tracksToShow.isEmpty) {
      return const Center(
        child: Text(
          "플레이리스트가 없습니다.",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      onReorder: (oldIndex, newIndex) {
        viewModel.reorderTracks(oldIndex, newIndex);
      },
      itemCount: tracksToShow.length,
      itemBuilder: (context, index) {
        final item = tracksToShow[index];
        final isSelected = state.selectedTracks.contains(item);

        return PlaylistTrackListTile(
          key: ValueKey(item.track.trackId),
          item: item,
          isSelected: isSelected,
          selectionMode: state.selectedTracks.isNotEmpty,
          onToggleSelection: () => viewModel.toggleTrackSelection(item),
          onTap: () => print("${item.track.trackTitle} 선택됨!"),
          onDelete: () {},
        );
      },
    );
  }
}

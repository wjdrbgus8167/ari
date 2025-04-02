import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/playlist/playlist_track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaylistTrackList extends ConsumerWidget {
  const PlaylistTrackList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistState = ref.watch(playlistViewModelProvider);

    if (playlistState.selectedPlaylist == null) {
      return const Center(
        child: Text('플레이리스트를 선택해 주세요.', style: TextStyle(color: Colors.white)),
      );
    }

    final tracks = playlistState.selectedPlaylist!.tracks;
    if (tracks.isEmpty) {
      return const Center(
        child: Text('트랙이 존재하지 않습니다.', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final trackItem = tracks[index];
        final isSelected = playlistState.selectedTracks.contains(trackItem);
        return PlaylistTrackListTile(
          item: trackItem,
          isSelected: isSelected,
          selectionMode: playlistState.selectionMode,
          onTap: () {
            // 트랙 클릭 시 동작을 구현합니다.
          },
          onToggleSelection: () {
            ref
                .read(playlistViewModelProvider.notifier)
                .toggleTrackSelection(trackItem);
          },
          onDelete: () {
            ref.read(playlistViewModelProvider.notifier).deleteTrack(trackItem);
          },
        );
      },
    );
  }
}

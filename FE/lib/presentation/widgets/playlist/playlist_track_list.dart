import 'package:ari/core/services/audio_service.dart';
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
            // AudioService의 play 메서드에 필요한 모든 매개변수를 전달합니다.
            ref
                .read(audioServiceProvider)
                .play(
                  ref,
                  trackItem.trackFileUrl,
                  title: trackItem.trackTitle,
                  artist: trackItem.artist, // 새 API 응답의 artist 필드 사용
                  coverImageUrl:
                      trackItem.coverImageUrl, // 새 API 응답의 coverImageUrl 사용
                  lyrics: trackItem.lyrics,
                  trackId: trackItem.trackId,
                  albumId: trackItem.albumId,
                  isLiked: false,
                );
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

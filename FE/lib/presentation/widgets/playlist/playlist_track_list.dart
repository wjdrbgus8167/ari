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

    final tracks =
        playlistState.filteredTracks?.isNotEmpty == true
            ? playlistState.filteredTracks!
            : playlistState.selectedPlaylist!.tracks;
    if (tracks.isEmpty) {
      return const Center(
        child: Text('트랙이 존재하지 않습니다.', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final trackItem = tracks[index];

        // isSelected 체크 시, 인덱스까지 고려해서 각각의 항목을 고유하게 판단할 수 있도록 수정
        final isSelected = playlistState.selectedTracks.contains(trackItem);

        return PlaylistTrackListTile(
          // ✅ 여기서 `key`를 인덱스 기준으로 다르게 주면 Flutter가 동일 트랙도 구분할 수 있음
          key: ValueKey('$index-${trackItem.trackId}'),
          item: trackItem,
          isSelected: isSelected,
          selectionMode: playlistState.selectionMode,
          onTap: () async {
            // 트랙 재생
            await ref
                .read(audioServiceProvider)
                .play(
                  ref,
                  trackItem.trackFileUrl,
                  title: trackItem.trackTitle,
                  artist: trackItem.artist,
                  coverImageUrl: trackItem.coverImageUrl,
                  lyrics: trackItem.lyrics,
                  trackId: trackItem.trackId,
                  albumId: trackItem.albumId,
                  isLiked: false,
                );
            // 재생목록(큐)에 트랙 추가 (domain -> data 모델 변환)
            await ref
                .read(listeningQueueProvider.notifier)
                .trackPlayed(trackItem.toDataTrack());
          },

          onToggleSelection: () {
            // 중복된 항목도 각자 다르게 선택되도록 하려면,
            // selectedTracks 를 List 또는 index 기반 구조로 바꾸는 것도 고려해볼 수 있음
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

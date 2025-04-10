import 'package:ari/core/services/audio_service.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/presentation/widgets/listening_queue/track_list_tile.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListeningQueueTrackList extends ConsumerWidget {
  const ListeningQueueTrackList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserIdProvider); // 그냥 바로 사용

    final state = ref.watch(listeningQueueProvider(userId));
    final viewModel = ref.read(listeningQueueProvider(userId).notifier);

    final tracks = state.filteredPlaylist;

    if (tracks.isEmpty) {
      return const Center(
        child: Text('재생 목록이 비어 있습니다.', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final item = tracks[index];
        final isSelected = state.selectedTracks.contains(item);
        final uniqueId =
            '$index-${item.track.trackId}-${item.track.trackTitle}';

        return TrackListTile(
          key: ValueKey(uniqueId),
          track: item.track,
          isSelected: isSelected,
          onToggleSelection: () {
            viewModel.toggleTrackSelection(item);
          },
          onTap: () {
            ref
                .read(audioServiceProvider)
                .playFromQueueSubset(
                  context,
                  ref,
                  state.filteredPlaylist
                      .map((e) => e.track)
                      .toList(), // 전체 재생목록
                  item.track, // 클릭한 트랙
                );
          },
          // onToggleSelection: () {
          //   viewModel.toggleTrackSelection(item);
          // },
        );
      },
    );
  }
}

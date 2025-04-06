// 전체 트랙 선택 라디오버튼, 곡수표시, 하나이상 선택시 우측 삭제버튼
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaylistTrackControls extends ConsumerWidget {
  const PlaylistTrackControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistViewModelProvider);
    final viewModel = ref.read(playlistViewModelProvider.notifier);

    final playlist = state.selectedPlaylist;
    final selectedTracks = state.selectedTracks;

    final allSelected =
        playlist != null &&
        playlist.tracks.every((item) => selectedTracks.contains(item));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (playlist != null) {
                viewModel.toggleSelectAll();
              }
            },
            child: Icon(
              allSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "전체곡 (${playlist?.tracks.length ?? 0}곡)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (selectedTracks.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final item in selectedTracks) {
                  viewModel.removeTrack(item);
                }
                context.showToast("선택된 트랙이 삭제되었습니다.");
              },
              child: const Text(
                "삭제하기",
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

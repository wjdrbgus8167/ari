import 'package:flutter/material.dart';
import 'package:ari/core/constants/app_colors.dart';
import 'package:ari/domain/entities/playlist_trackitem.dart';

class TrackCountBar extends StatelessWidget {
  final int trackCount;
  final Set<PlaylistTrackItem> selectedTracks;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onAddToPlaylist;

  const TrackCountBar({
    super.key,
    required this.trackCount,
    required this.selectedTracks,
    required this.onToggleSelectAll,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final bool allSelected =
        trackCount > 0 && selectedTracks.length == trackCount;
    return Container(
      width: double.infinity,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleSelectAll,
            child: Icon(
              allSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$trackCount곡',
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
              onPressed: onAddToPlaylist,
              child: const Text(
                "플레이리스트에 추가",
                style: TextStyle(color: AppColors.mediumPurple),
              ),
            ),
        ],
      ),
    );
  }
}

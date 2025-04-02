import 'package:ari/domain/entities/playlist_trackitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/core/services/audio_service.dart';

class PlaylistTrackListTile extends ConsumerWidget {
  final PlaylistTrackItem item;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onToggleSelection;
  final VoidCallback onDelete;

  const PlaylistTrackListTile({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onToggleSelection,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggleSelection,
            child: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              'assets/images/default_album_cover.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      title: Text(
        item.trackTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        item.composer,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white70),
        onPressed: onDelete,
      ),
      onTap: () {
        // AudioService의 play 메서드에 WidgetRef와 트랙 URL 전달
        ref.read(audioServiceProvider).play(ref, item.trackFileUrl);
      },
    );
  }
}

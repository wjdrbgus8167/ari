import 'package:ari/data/models/playlist_trackitem.dart';
import 'package:flutter/material.dart';

class PlaylistTrackListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final track = item.track;

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
        track.trackTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "${track.artist}",
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.menu, color: Colors.white70),
      onTap: onTap,
    );
  }
}

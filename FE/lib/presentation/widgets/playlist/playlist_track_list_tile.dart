import 'package:ari/domain/entities/playlist_trackitem.dart';
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
    // 바로 item의 필드를 사용합니다.
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
        item.trackTitle, // 직접 item에서 trackTitle 사용
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        item.composer, // 필요에 따라 작곡가 또는 아티스트 명 사용
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white70),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

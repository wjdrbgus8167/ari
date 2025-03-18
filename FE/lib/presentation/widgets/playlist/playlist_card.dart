import 'package:flutter/material.dart';
import '../../../data/models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 네트워크 URL이 비어있거나 에러 발생 시 기본 asset 이미지를 표시하도록 처리
    Widget imageWidget;
    if (playlist.coverUrl.isNotEmpty) {
      imageWidget = Image.network(
        playlist.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_playlist_cover.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/default_playlist_cover.png',
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AspectRatio를 사용해 이미지 영역을 정사각형(1:1)으로 설정
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

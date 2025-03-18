import 'package:ari/presentation/pages/album/album_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  const AlbumCard({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 네트워크 URL이 비어있지 않다면 Image.network를 사용하고,
    // 에러 발생 시 기본 asset 이미지를 표시합니다.
    Widget imageWidget;
    if (album.coverUrl.isNotEmpty) {
      imageWidget = Image.network(
        album.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_album_cover.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/default_album_cover.png',
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailPage(),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AspectRatio 위젯을 사용해 이미지 영역을 정사각형(1:1)으로 고정
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              album.artist,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
    );
  }
}

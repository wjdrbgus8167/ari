import 'package:flutter/material.dart';

class MediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle; // 부제목이 필요한 경우 (예: 앨범의 아티스트)
  final VoidCallback? onTap;
  final VoidCallback? onPlayPressed;

  const MediaCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onPlayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // imageUrl이 비어있지 않으면 네트워크 이미지, 아니면 기본 에셋 이미지를 사용
    Widget imageWidget;
    if (imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
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
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // 앨범/플레이리스트 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
                  // ⏯ 오른쪽 아래에 작은 재생 버튼
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        if (onPlayPressed != null) {
                          onPlayPressed!();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

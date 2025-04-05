import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:ari/presentation/widgets/common/media_card.dart';
import 'package:ari/domain/entities/album.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  const AlbumCard({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaCard(
      imageUrl: album.coverImageUrl,
      title: album.albumTitle,
      subtitle: album.artist,
      onTap: () {
        // 앨범 상세 페이지로 이동하는 로직 구현
        Navigator.pushNamed(
          context,
          AppRoutes.album,
          arguments: {'albumId': album.albumId},
        );
      },
    );
  }
}

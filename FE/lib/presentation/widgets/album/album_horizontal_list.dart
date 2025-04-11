import 'package:flutter/material.dart';
import 'package:ari/domain/entities/album.dart';
import 'album_card.dart';

class AlbumHorizontalList extends StatelessWidget {
  final List<Album> albums;
  const AlbumHorizontalList({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 앨범 커버가 들어갈 정도의 높이
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 9), // 헤더와 동일한 왼쪽(및 오른쪽) 간격 적용
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return AlbumCard(album: album);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/album.dart';
import 'album_card.dart';

class AlbumHorizontalList extends StatelessWidget {
  final List<Album> albums;
  const AlbumHorizontalList({Key? key, required this.albums}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 앨범 커버가 들어갈 정도의 높이
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return AlbumCard(album: album);
        },
      ),
    );
  }
}

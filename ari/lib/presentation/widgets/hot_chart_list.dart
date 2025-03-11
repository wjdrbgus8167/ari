import 'package:flutter/material.dart';
import '../../data/models/song.dart';

class HotChartList extends StatelessWidget {
  final List<Song> songs;
  const HotChartList({Key? key, required this.songs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // 부모의 스크롤뷰와 중첩되지 않도록 설정
      physics: const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Text('${index + 1}'),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () {
            // 노래 상세보기나 재생 로직 추가 가능
          },
        );
      },
    );
  }
}

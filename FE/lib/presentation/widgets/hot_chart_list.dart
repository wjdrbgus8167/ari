import 'package:flutter/material.dart';
import '../../data/models/track.dart' as ari;

class HotChartList extends StatefulWidget {
  final List<ari.Track> songs;
  const HotChartList({Key? key, required this.songs}) : super(key: key);

  @override
  _HotChartListState createState() => _HotChartListState();
}

class _HotChartListState extends State<HotChartList> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 오른쪽 페이지 일부 보이도록 viewportFraction 0.85 설정
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int itemsPerPage = 5;
    final int pageCount = (widget.songs.length / itemsPerPage).ceil();

    return PageView.builder(
      controller: _pageController,
      clipBehavior: Clip.none, // 자식 위젯이 부모 영역 넘어가도 보여지게 함
      itemCount: pageCount,
      itemBuilder: (context, pageIndex) {
        final int startIndex = pageIndex * itemsPerPage;
        final int endIndex =
            (startIndex + itemsPerPage) > widget.songs.length
                ? widget.songs.length
                : (startIndex + itemsPerPage);
        final List<ari.Track> pageTitles = widget.songs.sublist(
          startIndex,
          endIndex,
        );

        return Transform.translate(
          offset: const Offset(-10, 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  pageTitles.asMap().entries.map((entry) {
                    final localIndex = entry.key;
                    final song = entry.value;
                    final globalIndex = startIndex + localIndex;
                    return _ChartItem(rank: globalIndex + 1, song: song);
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ChartItem extends StatelessWidget {
  final int rank;
  final ari.Track song;

  const _ChartItem({Key? key, required this.rank, required this.song})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // 고정 높이
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 앨범 커버 컨테이너
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/default_album_cover.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 순위 컨테이너
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 제목 및 아티스트 컨테이너 (Expanded)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.trackTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 재생 버튼 컨테이너
          Container(
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                // 재생 로직 추가(예정)
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:ari/domain/entities/track.dart' as domain;
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ari/providers/global_providers.dart';

import 'package:ari/core/services/audio_service.dart';

class HotChartList extends StatefulWidget {
  final List<domain.Track> tracks;
  const HotChartList({super.key, required this.tracks});

  @override
  _HotChartListState createState() => _HotChartListState();
}

class _HotChartListState extends State<HotChartList> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 다음 페이지가 살짝 보이도록 0.85로 설정
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 한 페이지당 4개씩
    const int itemsPerPage = 4;
    final int totalTracks = widget.tracks.length;
    final int pageCount = (totalTracks / itemsPerPage).ceil();

    return PageView.builder(
      controller: _pageController,
      clipBehavior: Clip.none,
      itemCount: pageCount,
      itemBuilder: (context, pageIndex) {
        // 마지막 페이지인지 확인
        final bool isLastPage = pageIndex == pageCount - 1;

        final int startIndex = pageIndex * itemsPerPage;
        final int endIndex =
            (startIndex + itemsPerPage) > totalTracks
                ? totalTracks
                : (startIndex + itemsPerPage);
        final List<domain.Track> pageTracks = widget.tracks.sublist(
          startIndex,
          endIndex,
        );

        return Transform.translate(
          // 마지막 페이지라면 옆 페이지가 보이지 않도록 offset 제거
          offset: isLastPage ? Offset.zero : const Offset(-10, 0),
          child: Padding(
            // 마지막 페이지라면 우측 padding 제거
            padding: EdgeInsets.only(right: isLastPage ? 0 : 8, bottom: 8),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageTracks.length,
              itemBuilder: (context, index) {
                final globalIndex = startIndex + index;
                final track = pageTracks[index];
                return _ChartItem(
                  rank: globalIndex + 1,
                  track: track,
                  allTracks: widget.tracks,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// _ChartItem를 ConsumerWidget로 변경하여 Provider를 사용할 수 있도록 함.
class _ChartItem extends ConsumerWidget {
  final int rank;
  final domain.Track track;
  final List<domain.Track> allTracks;

  const _ChartItem({
    super.key,
    required this.rank,
    required this.track,
    required this.allTracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.album,
                  arguments: {'albumId': track.albumId},
                );
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    track.coverUrl ?? 'assets/images/default_album_cover.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_album_cover.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
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
          // 제목 및 아티스트
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.trackTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.artistName,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 재생 버튼
          SizedBox(
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                final userId = ref.read(authUserIdProvider);
                if (userId == null) return;

                final dataTrack = track.toDataModel();
                final audioService = ref.read(audioServiceProvider);

                await ref
                    .read(listeningQueueProvider.notifier)
                    .trackPlayed(dataTrack);

                await audioService.playFromQueueSubset(
                  context,
                  ref,
                  allTracks,
                  track,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

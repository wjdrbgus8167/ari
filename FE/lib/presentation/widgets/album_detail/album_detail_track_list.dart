import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/pages/track_detail/track_detail_screen.dart';
import 'package:flutter/material.dart';

class AlbumDetailTrackList extends StatelessWidget {
  final List<Track> tracks;
  
  const AlbumDetailTrackList({
    super.key,
    required this.tracks,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: tracks.asMap().entries.map((entry) {
                int index = entry.key;  // 인덱스 (0부터 시작)
                Track track = entry.value;
                return GestureDetector(
                  onTap: () {
                    // 트랙으로 이동하는 네비게이션
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackDetailScreen(trackId: track.id),
                      ),
                    );
                  },
                  child: Text(
                    '${index + 1}. ${track.trackTitle}',  // 숫자와 track을 결합
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    )
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
  //     clipBehavior: Clip.antiAlias,
  //     decoration: BoxDecoration(),
  //     width: double.infinity,
  //     child: Wrap(
  //       alignment: WrapAlignment.center,
  //       runAlignment: WrapAlignment.center,
  //       spacing: 10,
  //       runSpacing: 10,
        
  //     ),
  //   );
  // }

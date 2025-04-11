import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';

class AlbumDetailTrackList extends StatelessWidget {
  final List<Track> tracks;
  final String albumCoverUrl;

  const AlbumDetailTrackList({
    super.key,
    required this.tracks,
    required this.albumCoverUrl,
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
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children:
                  tracks.asMap().entries.map((entry) {
                    int index = entry.key; // 인덱스 (0부터 시작)
                    Track track = entry.value;
                    return GestureDetector(
                      onTap: () {
                        print('앨범이미지url : $albumCoverUrl');
                        Navigator.of(context).pushNamed(
                          AppRoutes.track,
                          arguments: {
                            'albumId': track.albumId, // 앨범 ID 추가
                            'trackId': track.trackId, // 트랙 ID 추가
                            'albumCoverUrl': albumCoverUrl,
                          },
                        );
                      },
                      child: Text(
                        '${index + 1}. ${track.trackTitle}', // 숫자와 track을 결합
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
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

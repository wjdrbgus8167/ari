import 'package:flutter/material.dart';

class AlbumDetailTrackList extends StatelessWidget {
  final List<String> tracks;
  
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
                String track = entry.value;
                return Text(
                  '${index + 1}. $track',  // 숫자와 track을 결합
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                  )
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

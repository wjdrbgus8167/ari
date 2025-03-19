import 'package:flutter/material.dart';

class AlbumDetailTrackList extends StatelessWidget {
  final List<String> tracks;
  
  const AlbumDetailTrackList({
    super.key,
    required this.tracks,
  });
  
  @override
  Widget build(BuildContext context) {
    print(tracks);
    return Container(
      width: 320,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(),
      child: Wrap(
        spacing: 10, // 가로 간격
        runSpacing: 10, // 세로 간격 
        alignment: WrapAlignment.center,
        children: tracks.map((track) => 
          Container(
            child: Text(
              track,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ).toList(),
      ),
    );
  }
}
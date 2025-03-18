import 'package:flutter/material.dart';

class AlbumDetailTrackList extends StatelessWidget {
  const AlbumDetailTrackList({super.key});
  
  @override
  Widget build(BuildContext context) {
    final tracks = [
      'ALONE AGAIN',
      'TOO LATE',
      'HARDEST TO LOVE',
      'SCARED TO LIVE',
      'SNOWCHILD',
      'ESCAPE FROM LA',
      'HEARTLESS',
      'FAITH',
      'BLINDING LIGHTS',
      'IN YOUR EYES',
      'SAVE YOUR TEARS',
      'REPEAT AFTER ME (INTERLUDE)',
      'AFTER HOURS',
      'UNTIL I BLEED OUT',
    ];

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
import 'package:flutter/material.dart';

class AlbumDetailDescription extends StatelessWidget {
  const AlbumDetailDescription({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Text(
              '앨범 소개',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 19),
          SizedBox(
            width: 320,
            child: Text(
              '위켄드의 AFTER HOURS는 어둠과 빛이 공존하는 도시의 심야 풍경을 담아낸 앨범입니다. 특유의 몽환적인 사운드와 감각적인 비트가 어우러져, 사랑의 열정과 상실, 고독의 미묘한 감정을 섬세하게 표현합니다. 음산하면서도 매혹적인 멜로디를 통해, 청자는 밤의 고요함 속에서 내면의 감정을 탐색하게 되며, 위켄드의 성숙한 예술 세계에 빠져들게 됩니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
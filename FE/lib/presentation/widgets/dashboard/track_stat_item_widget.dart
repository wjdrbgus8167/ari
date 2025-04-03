import 'package:ari/presentation/viewmodels/dashboard/track_stat_list_viewmodel.dart';
import 'package:flutter/material.dart';

class TrackStatItem extends StatelessWidget {
  final TrackStat trackStat;
  final int index;

  const TrackStatItem({
    Key? key,
    required this.trackStat,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 순위 번호
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 트랙 이미지
          Container(
            width: 45,
            height: 45,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(trackStat.imageUrl),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          const SizedBox(width: 10),
          // 트랙 정보
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 트랙 제목
                Text(
                  trackStat.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                // 재생 정보
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월간 재생 수
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '월간 재생 수',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 8,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '${trackStat.monthlyPlayCount}',
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 8,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // 누적 재생 수
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '누적 재생 수',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 8,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '${trackStat.totalPlayCount}',
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 8,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  final SortBy sortBy;
  final VoidCallback onPressed;

  const SortButton({
    Key? key,
    required this.sortBy,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            sortBy == SortBy.totalPlayCount ? '누적 재생 수' : '월간 재생 수',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4), // 간격 추가
          Transform.rotate(
            angle: 1.57,
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD9D9D9),
              size: 16,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

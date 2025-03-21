import 'package:flutter/material.dart';

class TrackDetailCommentHeader extends StatelessWidget {
  final int commentCount;
  
  const TrackDetailCommentHeader({
    super.key,
    required this.commentCount,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,  // 전체 너비 사용
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),  // 좌우 패딩 추가
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 양쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 텍스트 그룹
          Row(
            children: [
              Text(
                '댓글 $commentCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          // 오른쪽 텍스트
          Text(
            '전체보기',
            style: const TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
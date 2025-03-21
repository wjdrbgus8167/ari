import 'package:ari/data/models/track_detail.dart';
import 'package:flutter/material.dart';

class TrackDetailComments extends StatelessWidget {
  final TrackCommentModel comment;
  
  const TrackDetailComments({
    super.key,
    required this.comment,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 유저 정보 행
          Row(
            children: [
              // 프로필 이미지 - 네트워크 이미지 대신 로컬 아이콘 사용
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 0.5, color: Colors.white30),
                ),
                child: const Icon(Icons.person, size: 20, color: Colors.white70),
              ),
              const SizedBox(width: 10),
              // 사용자 이름 - 실제 댓글의 닉네임 사용
              Text(
                comment.nickname ?? '사용자',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 댓글 내용
          Text(
            comment.content ?? '내용 없음',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          // 댓글 하단 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 타임스탬프 표시
              Text(
                comment.contentTimestamp ?? '00:00',
                style: const TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontSize: 11,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
              // 옵션 아이콘 - 네트워크 이미지 대신 로컬 아이콘 사용
              const Icon(
                Icons.more_horiz,
                size: 20,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 구분선
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFF838282),
          ),
        ],
      ),
    );
  }
}
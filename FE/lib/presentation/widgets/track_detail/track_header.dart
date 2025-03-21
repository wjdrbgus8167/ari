import 'package:flutter/material.dart';

class TrackHeader extends StatelessWidget {
  final String albumName;
  final String trackTitle;
  final String artistName;
  final String likeCount;
  final String commentCount;
  final String playCount;
  final String albumImageUrl;
  final String artistImageUrl;

  const TrackHeader({
    Key? key,
    required this.albumName,
    required this.trackTitle,
    required this.artistName,
    required this.likeCount,
    required this.commentCount,
    required this.playCount,
    required this.albumImageUrl,
    required this.artistImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 정보 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  // 앨범명
                  Row(children: [
                    Text(
                      albumName,
                      style: const TextStyle(
                        color: Color(0xFF9D9D9D),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 1),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9D9D9D),
                      size: 14,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // 트랙 제목
                  Text(
                    trackTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 아티스트 정보
                  Row(
                    children: [
                      // 아티스트 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          artistImageUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(Icons.person, size: 16, color: Colors.white70),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      // 아티스트 이름
                      Expanded(
                        child: Text(
                          artistName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 좋아요, 댓글, 재생 횟수 정보
                  Row(
                    children: [
                      // 좋아요 카운트
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const ShapeDecoration(
                              color: Color(0x19F74440),
                              shape: OvalBorder(),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              size: 12,
                              color: Color(0xFFF74440),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            likeCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 9),
                      // 댓글 카운트
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            commentCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 9),
                      // 재생 횟수
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 1),
                        Text(
                          playCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],)
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 앨범 커버 이미지
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                albumImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.album, size: 50, color: Colors.white70),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
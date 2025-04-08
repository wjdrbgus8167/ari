import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';

class AlbumDetailTitle extends StatelessWidget {
  final String title;
  final String artist;
  final int artistId;
  final int viewCount;
  final int commentCount;
  final String rating;
  final String genre;
  final String releaseDate;

  const AlbumDetailTitle({
    super.key,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.viewCount,
    required this.commentCount,
    required this.rating,
    required this.genre,
    required this.releaseDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              print('[DEBUG] 아티스트 채널로 이동: artistId = $artistId');

              Navigator.pushNamed(
                context,
                AppRoutes.myChannel,
                arguments: {'memberId': artistId.toString()},
              );
            },
            child: Text(
              artist,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline, // 클릭 가능한 느낌 강조
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 7,
            children: [
              // 뷰 카운트
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 3,
                children: [
                  // 하트 아이콘 (뷰 카운트 부분에)
                  SizedBox(
                    width: 12.5,
                    height: 12.5,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 12.5,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    viewCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 7),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 댓글 카운트
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    commentCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 7),

              // 평점
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                crossAxisAlignment: CrossAxisAlignment.center, // 수직 가운데 정렬
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Icon(
                          Icons.star,
                          color: Color(0xFF8A4FFF),
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 장르 및 발매일
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.50,
                      color: Color(0xFF989595),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Apple SD Gothic Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.50,
                      color: Color(0xFF989595),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  releaseDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Apple SD Gothic Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

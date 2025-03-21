import 'package:ari/domain/entities/album_comment.dart';
import 'package:flutter/material.dart';

class AlbumDetailComments extends StatelessWidget {
  final AlbumComment comment;
  
  const AlbumDetailComments({
    super.key,
    required this.comment,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/30x30"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 0.50),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '앨범이 좋으면 소화기를 부는 남자',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  child: Text(
                    '댓글 작성',
                    style: TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontSize: 11,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/35x15"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Color(0xFF838282),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
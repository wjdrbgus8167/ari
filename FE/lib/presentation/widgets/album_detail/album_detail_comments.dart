import 'package:flutter/material.dart';

class AlbumDetailComments extends StatelessWidget {
  const AlbumDetailComments({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
    width: 320,
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
            Container(
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                        Container(
                            width: 30,
                            height: 30,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                                image: DecorationImage(
                                    image: NetworkImage("https://placehold.co/30x30"),
                                    fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 0.50),
                                    borderRadius: BorderRadius.circular(50),
                                ),
                            ),
                            child: Stack(
                                children: [
                                    Positioned(
                                        left: -6,
                                        top: 0,
                                        child: Container(
                                            width: 36.05,
                                            height: 43,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage("https://placehold.co/36x43"),
                                                    fit: BoxFit.cover,
                                                ),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Text(
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
            ),
            Container(
              width: double.infinity,
              child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Container(
                            height: 35,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Expanded(
                                        child: Container(
                                            width: double.infinity,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 303,
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
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage("https://placehold.co/15x15"),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
 
                          ),
                          Container(
                            width: 318,
                            decoration: ShapeDecoration(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
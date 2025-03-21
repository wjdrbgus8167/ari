import 'package:flutter/material.dart';

class TrackCredit extends StatelessWidget {
  final String title;
  final String trackName;
  final List<String> lyricists;
  final List<String> composers;
  final List<String> genres;

  const TrackCredit({
    Key? key,
    required this.title,
    required this.trackName,
    required this.lyricists,
    required this.composers,
    required this.genres,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 320,
            child: Text(
              trackName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 작사 섹션
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '작사',
                  style: TextStyle(
                    color: Color(0xFF989595),
                    fontSize: 12,
                    fontFamily: 'Apple SD Gothic Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                ...lyricists.map((lyricist) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 0.8,
                            color: Color(0xFF989595),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            lyricist,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Apple SD Gothic Neo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 작곡 섹션
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '작곡',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF989595),
                    fontSize: 12,
                    fontFamily: 'Apple SD Gothic Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                ...composers.map((composer) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 0.8,
                            color: Color(0xFF989595),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            composer,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Apple SD Gothic Neo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ).toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 장르 섹션
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '장르',
                  style: TextStyle(
                    color: Color(0xFF989595),
                    fontSize: 12,
                    fontFamily: 'Apple SD Gothic Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                ...genres.map((genre) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 0.8,
                            color: Color(0xFF989595),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            genre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Apple SD Gothic Neo',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
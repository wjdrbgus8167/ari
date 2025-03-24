import 'package:flutter/material.dart';

/// 가로 스크롤 카로셀 컴포넌트
/// 앨범이나 플레이리스트 등에 사용!
class CarouselContainer extends StatelessWidget {
  final String title; // 카로셀 섹션 제목
  final List<Widget> children; // 카로셀에 표시될 위젯 목록
  final double height; // 카로셀 높이
  final double itemWidth; // 각 아이템 너비
  final double itemSpacing; // 아이템 간 간격
  final EdgeInsetsGeometry padding; // 카로셀 패딩

  const CarouselContainer({
    Key? key,
    required this.title,
    required this.children,
    this.height = 220.0, // 기본 높이
    this.itemWidth = 160.0, // 기본 아이템 너비
    this.itemSpacing = 12.0, // 기본 간격
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: const Color(0xFF1A1A1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카로셀 제목
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          
          // 가로 스크롤 가능한 항목 목록
          SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 가로 스크롤 설정
              physics: const BouncingScrollPhysics(), // 스크롤 효과
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: children.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == children.length - 1 ? 0 : itemSpacing,
                  ),
                  child: SizedBox(
                    width: itemWidth,
                    child: children[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// <카로셀 사용 예시>
/// CarouselContainer(
///   title: "인기 앨범",
///   children: albums.map((album) => AlbumCard(album: album)).toList(),
/// )
///
/// CarouselContainer(
///   title: "인기 플레이리스트",
///   children: playlists.map((playlist) => PlaylistCard(playlist: playlist)).toList(),
///   height: 180.0, // 높이 조절할 수 있고
///   itemWidth: 140.0, // 아이템 너비도 조절할 수 있어요
/// )
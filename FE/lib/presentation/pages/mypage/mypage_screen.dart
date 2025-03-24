import 'package:flutter/material.dart';
import '../../widgets/common/carousel_container.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    // 테스트용 앨범 데이터 생성
    // 원래라면 API 호출 해야함
    final myAlbums = List.generate(
      8,
      (index) => _AlbumData(
        id: 'album_$index',
        title: '앨범 ${index + 1}',
        artist: '아티스트 ${index + 1}',
        coverImage: 'assets/images/default_album_cover.png',
      ),
    );

    // 테스트용 플레이리스트 데이터 생성
    // 원래라면 API 호출 해야함
    final myPlaylists = List.generate(
      6,
      (index) => _PlaylistData(
        id: 'playlist_$index',
        title: '플레이리스트 ${index + 1}',
        trackCount: (index + 3) * 2,
        coverImage: 'assets/images/default_album_cover.png',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이 부분은 나중에 마이페이지 UI 할 때 참고할 수도 있을 것 같아서 남겨둡니다
            // 사용자 정보 영역
            Container(
              padding: const EdgeInsets.all(20.0),
              color: const Color(0xFF1A1A1A),
              child: Row(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 사용자 이름과 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '사용자 닉네임',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'user@example.com',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 내 플레이리스트 카로셀
            // height-> 전체 높이를 조절 가능
            CarouselContainer(
              title: '내 플레이리스트',
              height: 190.0, // 카로셀 전체 높이 설정
              children:
                  myPlaylists
                      .map((playlist) => _PlaylistCard(playlist: playlist))
                      .toList(), // 플레이리스트 데이터를 카드 위젯으로 변환
            ),

            // 최근 재생 트랙 카로셀
            // itemWidth 속성으로 각 아이템의 너비를 조절할 수 있음
            CarouselContainer(
              title: '최근 재생',
              height: 200.0, // 카로셀 전체 높이 설정
              itemWidth: 140.0, // 각 아이템의 너비 설정 (더 작은 크기로)
              children:
                  myAlbums.reversed
                      .map((album) => _AlbumCard(album: album))
                      .toList(),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF121212), // 배경색 설정
    );
  }
}

// 테스트용 앨범 카드 위젯
// 앨범을 표시하는 카드 UI 컴포넌트
class _AlbumCard extends StatelessWidget {
  final _AlbumData album; // 표시할 앨범 데이터

  const _AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 앨범 커버 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            album.coverImage,
            width: double.infinity, // 부모 위젯 너비에 맞춤
            height: 140, // 이미지 높이 고정
            fit: BoxFit.cover, // 이미지 비율 유지하며 채우기
          ),
        ),
        const SizedBox(height: 8),
        // 앨범 제목 - 한 줄로 제한하고 넘칠 경우 말줄임표(..)
        Text(
          album.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // 아티스트 이름 - 회색, 한 줄 제한
        Text(
          album.artist,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// 테스트용 플레이리스트 카드 위젯
// 플레이리스트를 표시하는 카드 UI 컴포넌트
class _PlaylistCard extends StatelessWidget {
  final _PlaylistData playlist;

  const _PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 플레이리스트 커버 이미지와 재생 버튼 오버레이
        Stack(
          children: [
            // 커버 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                playlist.coverImage,
                width: double.infinity, // 부모 위젯 너비에 맞춤
                height: 140, // 이미지 높이
                fit: BoxFit.cover, // 이미지 비율 유지하며 채우기
              ),
            ),
            // play 아이콘 오버레이
            Positioned.fill(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 157, 252), // 분홍색
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 플레이리스트 제목 - 한 줄로 제한하고 넘칠 경우 말줄임표(..)
        Text(
          playlist.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // 트랙 개수 정보 - 회색
        Text(
          '${playlist.trackCount}곡',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}

////////////////////////////////////////
// 테스트용 앨범 데이터 모델
// 앨범 정보를 담는 데이터 클래스
class _AlbumData {
  final String id; // 앨범 고유 식별자
  final String title; // 앨범 제목
  final String artist; // 아티스트 이름
  final String coverImage; // 커버 이미지 경로

  _AlbumData({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImage,
  });
}

// 테스트용 플레이리스트 데이터 모델
// 플레이리스트 정보를 담는 데이터 클래스
class _PlaylistData {
  final String id; // 플레이리스트 고유 식별자
  final String title; // 플레이리스트 제목
  final int trackCount; // 수록곡 개수
  final String coverImage; // 커버 이미지 경로

  _PlaylistData({
    required this.id,
    required this.title,
    required this.trackCount,
    required this.coverImage,
  });
}

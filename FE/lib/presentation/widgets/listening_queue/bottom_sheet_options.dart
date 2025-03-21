import 'package:ari/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import '../../../data/models/track.dart';

class BottomSheetOptions extends StatelessWidget {
  final Track track;
  const BottomSheetOptions({Key? key, required this.track}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 트랙 정보 영역
          _buildTrackInfo(),
          const SizedBox(height: 20),
          _buildOptionTile(context, '앨범으로 이동'),
          _buildOptionTile(context, '트랙 정보로 이동'),
          _buildOptionTile(context, '아티스트 채널로 이동'),
        ],
      ),
    );
  }

  Widget _buildTrackInfo() {
    return Container(
      width: double.infinity,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 트랙 커버 이미지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image:
                    track.coverUrl != null && track.coverUrl!.isNotEmpty
                        ? NetworkImage(track.coverUrl!)
                        : const AssetImage(
                              'assets/images/default_album_cover.png',
                            )
                            as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 트랙 제목과 아티스트
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.trackTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artist,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 좋아요 버튼 (동작은 필요에 맞게 구현)
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // 좋아요 버튼 동작 구현
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        // 바텀시트 닫기
        Navigator.pop(context);
        // "앨범으로 이동" 옵션 선택 시 앨범 상세 페이지로 이동
        if (title == '앨범으로 이동') {
          Navigator.pushNamed(context, AppRoutes.album);
        } else if (title == '트랙 정보로 이동') {
          Navigator.pushNamed(context, AppRoutes.track);
        }
        // 다른 옵션에 대해서는 필요한 네비게이션 로직 추가 가능
      },
    );
  }
}

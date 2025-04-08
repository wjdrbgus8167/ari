import 'package:ari/data/mappers/track_mapper.dart';
import 'package:ari/data/models/track.dart' as data;
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/streaming_log_modal.dart';
import 'package:ari/core/utils/safe_to_domain_track.dart';

class TrackHeader extends ConsumerWidget {
  final int albumId;
  final String albumName;
  final String trackTitle;
  final String artistName;
  final int likeCount;
  final int commentCount;
  final int? playCount;
  final String albumImageUrl;
  final String artistImageUrl;
  final int trackId;
  final String trackFileUrl;
  final int artistId;

  const TrackHeader({
    super.key,
    required this.albumId,
    required this.albumName,
    required this.trackTitle,
    required this.artistName,
    required this.likeCount,
    required this.commentCount,
    required this.playCount,
    required this.albumImageUrl,
    required this.artistImageUrl,
    required this.trackId,
    required this.trackFileUrl,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Row(
                    children: [
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
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF9D9D9D),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 🔥 트랙 제목 + 아이콘 (인라인 밀착)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          trackTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          final audioService = ref.read(audioServiceProvider);
                          final queueNotifier = ref.read(
                            listeningQueueProvider.notifier,
                          );

                          final currentTrack = data.Track(
                            artistId: artistId,
                            id: trackId,
                            trackTitle: trackTitle,
                            artist: artistName,
                            composer: '',
                            lyricist: '',
                            albumId: albumId,
                            trackFileUrl: trackFileUrl,
                            lyrics: '',
                            coverUrl: albumImageUrl,
                            trackLikeCount: likeCount,
                          );

                          await queueNotifier.trackPlayed(currentTrack);

                          final fullQueue =
                              ref
                                  .read(listeningQueueProvider)
                                  .playlist
                                  .map((e) => safeToDomainTrack(e.track))
                                  .toList();

                          await audioService.playFromQueueSubset(
                            context,
                            ref,
                            fullQueue,
                            currentTrack.toDomainTrack(),
                          );
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 아티스트 정보
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          artistImageUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.myChannel,
                              arguments: {
                                'memberId': artistId.toString(), // 라우팅용 문자열로 변환
                              },
                            );
                          },
                          child: Text(
                            artistName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration:
                                  TextDecoration.underline, // 선택 사항: 링크 느낌
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 좋아요/댓글/재생 횟수
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$likeCount',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$commentCount',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 9),
                      GestureDetector(
                        onTap: () {
                          context.showStreamingHistoryModal(
                            albumId: albumId,
                            trackId: trackId,
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 1),
                            Text(
                              playCount == null
                                  ? "불러오는 중..."
                                  : '$playCount회 재생',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 앨범 커버
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                albumImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.album,
                      size: 60,
                      color: Colors.white70,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

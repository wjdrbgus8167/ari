import 'package:ari/data/mappers/track_mapper.dart';
import 'package:ari/data/models/track.dart' as data;
import 'package:ari/core/services/audio_service.dart';
import 'package:ari/presentation/routes/app_router.dart';
import 'package:ari/providers/global_providers.dart';
import 'package:ari/providers/like_track_datasource_provider.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/presentation/widgets/streaming_log_modal.dart';
import 'package:ari/core/utils/safe_to_domain_track.dart';

class TrackHeader extends ConsumerStatefulWidget {
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
  ConsumerState<TrackHeader> createState() => _TrackHeaderState();
}

class _TrackHeaderState extends ConsumerState<TrackHeader> {
  bool isLiked = false; // 초기값 false로 설정
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likeCount;
    _fetchInitialLikeStatus();
  }

  Future<void> _fetchInitialLikeStatus() async {
    final likeDatasource = ref.read(likeRemoteDatasourceProvider);
    final liked = await likeDatasource.fetchLikeStatus(widget.trackId);
    setState(() {
      isLiked = liked;
    });
  }

  Future<void> _toggleLike() async {
    final likeDatasource = ref.read(likeRemoteDatasourceProvider);
    await likeDatasource.toggleLikeStatus(
      albumId: widget.albumId,
      trackId: widget.trackId,
    );
    final updatedStatus = await likeDatasource.fetchLikeStatus(widget.trackId);
    setState(() {
      isLiked = updatedStatus;
      likeCount += isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.read(audioServiceProvider);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                        widget.albumName,
                        style: const TextStyle(
                          color: Color(0xFF9D9D9D),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 1),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF9D9D9D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.trackTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          final currentTrack = data.Track(
                            artistId: widget.artistId,
                            id: widget.trackId,
                            trackTitle: widget.trackTitle,
                            artist: widget.artistName,
                            composer: '',
                            lyricist: '',
                            albumId: widget.albumId,
                            trackFileUrl: widget.trackFileUrl,
                            lyrics: '',
                            coverUrl: widget.albumImageUrl,
                            trackLikeCount: likeCount,
                          );
                          final userId = ref.read(authUserIdProvider);
                          if (userId == null) return;

                          await ref
                              .read(listeningQueueProvider.notifier)
                              .trackPlayed(currentTrack);

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
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          widget.artistImageUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(Icons.person),
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
                                'memberId': widget.artistId.toString(),
                              },
                            );
                          },
                          child: Text(
                            widget.artistName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color:
                                  isLiked ? Colors.redAccent : Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$likeCount',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
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
                            '${widget.commentCount}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 9),
                      GestureDetector(
                        onTap: () {
                          context.showStreamingHistoryModal(
                            albumId: widget.albumId,
                            trackId: widget.trackId,
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 1),
                            Text(
                              widget.playCount == null
                                  ? "불러오는 중..."
                                  : '${widget.playCount}회 재생',
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.albumImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(
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
